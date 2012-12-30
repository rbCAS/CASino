require 'spec_helper'

describe CASinoCore::Processor::API::LoginCredentialAcceptor do
  describe '#process' do
    let(:listener) { Object.new }
    let(:processor) { described_class.new(listener) }

    context 'with invalid credentials' do
      let(:login_data) { {username: 'testuser', password: 'wrong'} }

      it 'calls the #invalid_login_credentials method on the listener' do
        listener.should_receive(:invalid_login_credentials_via_api)
        processor.process(login_data).should be_false
      end
    end

    context 'with valid credentials' do
      let(:login_data) { {username: 'testuser', password: 'foobar123'} }

      before(:each) do
        listener.stub(:user_logged_in)
      end

      it 'calls the #user_logged_in method on the listener' do
        listener.should_receive(:user_logged_in_via_api).with(/^TGC\-/)
        processor.process(login_data)
      end

      it 'generates a ticket-granting ticket' do
        listener.should_receive(:user_logged_in_via_api).with(/^TGC\-/)
        expect {
          processor.process(login_data)
        }.to change(CASinoCore::Model::TicketGrantingTicket, :count).by(1)
      end
    end
  end
end
