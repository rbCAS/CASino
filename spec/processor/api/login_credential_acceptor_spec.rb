require 'spec_helper'

describe CASino::API::LoginCredentialAcceptorProcessor do
  describe '#process' do
    let(:listener) { Object.new }
    let(:processor) { described_class.new(listener) }
    let(:user_agent) { 'ThisIsATestBrwoser 1.0' }

    context 'with invalid credentials' do
      let(:login_data) { { username: 'testuser', password: 'wrong' } }

      before(:each) do
        listener.stub(:invalid_login_credentials_via_api)
      end

      it 'calls the #invalid_login_credentials_via_api method on the listener' do
        listener.should_receive(:invalid_login_credentials_via_api)
        processor.process(login_data, user_agent).should be_false
      end

      it 'does not generate a ticket-granting ticket' do
        expect {
          processor.process(login_data, user_agent)
        }.to_not change(CASino::TicketGrantingTicket, :count)
      end
    end

    context 'with valid credentials' do
      let(:login_data) { { username: 'testuser', password: 'foobar123' } }

      before(:each) do
        listener.stub(:user_logged_in_via_api)
      end

      it 'calls the #user_logged_in_via_api method on the listener' do
        listener.should_receive(:user_logged_in_via_api).with(/^TGC\-/)
        processor.process(login_data, user_agent)
      end

      it 'generates a ticket-granting ticket' do
        expect {
          processor.process(login_data, user_agent)
        }.to change(CASino::TicketGrantingTicket, :count).by(1)
      end

      it 'sets the user-agent in the ticket-granting ticket' do
        processor.process(login_data, user_agent)
        CASino::TicketGrantingTicket.last.user_agent.should == user_agent
      end
    end
  end
end
