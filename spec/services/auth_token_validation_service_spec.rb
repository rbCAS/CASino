require 'spec_helper'

describe CASino::AuthTokenValidationService do
  let(:token) { 'le_token' }
  let(:signature) { 'le_signature' }

  subject { described_class.new(token, signature) }

  context 'without any token signers' do
    before(:each) do
      Dir.stub(:glob).with(CASino::AuthTokenValidationService::AUTH_TOKEN_SIGNERS_GLOB).and_return(nil)
    end

    its(:user_data) { should == nil }
    its(:validation_result) { should == nil }
  end

  context 'with token signers' do
    let(:signer_path) { '/test.pem' }
    let(:signer_path_content) { 'this_is_le_certificate' }
    let(:digest) { 'le_digest' }
    let(:rsa_stub) do
      double(OpenSSL::PKey::RSA).tap do |mock|
        mock.stub(:verify).with(digest, signature, token).and_return(signature_valid)
      end
    end

    before(:each) do
      Dir.stub(:glob).with(CASino::AuthTokenValidationService::AUTH_TOKEN_SIGNERS_GLOB) do |&block|
        block.call(signer_path)
      end
      File.stub(:read).with(signer_path).and_return(signer_path_content)
      OpenSSL::Digest::SHA256.stub(:new).and_return(digest)
      OpenSSL::PKey::RSA.stub(:new).with(signer_path_content).and_return(rsa_stub)
    end

    context 'with an invalid signature' do
      let(:signature_valid) { false }

      its(:user_data) { should == nil }
      its(:validation_result) { should == nil }
    end

    context 'with a valid signature' do
      let(:signature_valid) { true }

      before(:each) do
        CASino::AuthTokenTicket.stub(:consume).and_return(ticket_valid)
      end

      context 'with an invalid ticket' do
        let(:ticket_valid) { false }

        its(:user_data) { should == nil }
        its(:validation_result) { should == nil }
      end

      context 'with a valid ticket' do
        let(:ticket_valid) { true }

        before(:each) do
          JSON.stub(:parse).and_return(token_data)
        end

        context 'with invalid user data' do
          let(:token_data) { { authenticator: 'test', username: 'example' } }

          its(:user_data) { should == nil }
          its(:validation_result) { should == nil }
        end

        context 'with valid user data' do
          let(:token_data) { { authenticator: 'static', username: 'testuser' } }
          let(:user_data) { { username: 'testuser', extra_attributes: { "name" => "Test User", "game" => [ "StarCraft 2", "Doto" ] } } }
          let(:validation_result) { { authenticator: 'static', user_data: user_data } }

          its(:user_data) { should == user_data }
          its(:validation_result) { should == validation_result }
        end
      end
    end
  end
end
