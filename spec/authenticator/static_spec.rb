require 'spec_helper'

describe CASino::StaticAuthenticator do
  subject {
    described_class.new({
      users: {
        user: {
          password: 'testing123',
          fullname: 'Example User'
        }
      }
    })
  }

  context '#validate' do
    context 'with invalid credentials' do
      it 'returns false for an unknown username' do
        subject.validate('foobar', 'test').should == false
      end

      it 'returns false for a known username with wrong password' do
        subject.validate('user', 'test').should == false
      end
    end

    context 'with valid credentials' do
      let(:result) { subject.validate('user', 'testing123') }

      it 'does not return false' do
        result.should_not == false
      end

      it 'returns the username' do
        result[:username].should == 'user'
      end

      it 'returns extra attributes' do
        result[:extra_attributes][:fullname].should == 'Example User'
      end
    end
  end
end
