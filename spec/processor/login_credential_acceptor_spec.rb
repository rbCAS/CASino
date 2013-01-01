require 'spec_helper'

describe CASinoCore::Processor::LoginCredentialAcceptor do
  describe '#process' do
    let(:listener) { Object.new }
    let(:processor) { described_class.new(listener) }

    context 'without a valid login ticket' do
      it 'calls the #invalid_login_ticket method on the listener' do
        listener.should_receive(:invalid_login_ticket).with(kind_of(CASinoCore::Model::LoginTicket))
        processor.process
      end
    end

    context 'with an expired login ticket' do
      let(:expired_login_ticket) { FactoryGirl.create :login_ticket, :expired }

      it 'calls the #invalid_login_ticket method on the listener' do
        listener.should_receive(:invalid_login_ticket).with(kind_of(CASinoCore::Model::LoginTicket))
        processor.process(lt: expired_login_ticket.ticket)
      end
    end

    context 'with a valid login ticket' do
      let(:login_ticket) { FactoryGirl.create :login_ticket }

      context 'with invalid credentials' do
        it 'calls the #invalid_login_credentials method on the listener' do
          listener.should_receive(:invalid_login_credentials).with(kind_of(CASinoCore::Model::LoginTicket))
          processor.process(lt: login_ticket.ticket)
        end
      end

      context 'with valid credentials' do
        let(:service) { 'https://www.example.org' }
        let(:login_data) { { lt: login_ticket.ticket, username: 'testuser', password: 'foobar123', service: service } }

        before(:each) do
          listener.stub(:user_logged_in)
        end

        context 'when all authenticators raise an error' do
          before(:each) do
            CASinoCore::Authenticator::Static.any_instance.stub(:validate) do
              raise CASinoCore::Authenticator::AuthenticatorError, 'error123'
            end
          end

          it 'calls the #invalid_login_credentials method on the listener' do
            listener.should_receive(:invalid_login_credentials).with(kind_of(CASinoCore::Model::LoginTicket))
            processor.process(login_data)
          end
        end

        context 'without a service' do
          let(:service) { nil }

          it 'calls the #user_logged_in method on the listener' do
            listener.should_receive(:user_logged_in).with(nil, /^TGC\-/)
            processor.process(login_data)
          end

          it 'generates a ticket-granting ticket' do
            lambda do
              processor.process(login_data)
            end.should change(CASinoCore::Model::TicketGrantingTicket, :count).by(1)
          end
        end

        context 'with a service' do
          let(:service) { 'https://www.example.com' }

          it 'calls the #user_logged_in method on the listener' do
            listener.should_receive(:user_logged_in).with(/^#{service}\?ticket=ST\-/, /^TGC\-/)
            processor.process(login_data)
          end

          it 'generates a service ticket' do
            lambda do
              processor.process(login_data)
            end.should change(CASinoCore::Model::ServiceTicket, :count).by(1)
          end

          it 'generates a ticket-granting ticket' do
            lambda do
              processor.process(login_data)
            end.should change(CASinoCore::Model::TicketGrantingTicket, :count).by(1)
          end
        end
      end
    end
  end
end
