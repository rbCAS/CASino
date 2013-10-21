require 'spec_helper'

describe CASino::LoginCredentialAcceptorProcessor do
  describe '#process' do
    let(:listener) { Object.new }
    let(:processor) { described_class.new(listener) }

    context 'without a valid login ticket' do
      it 'calls the #invalid_login_ticket method on the listener' do
        listener.should_receive(:invalid_login_ticket).with(kind_of(CASino::LoginTicket))
        processor.process
      end
    end

    context 'with an expired login ticket' do
      let(:expired_login_ticket) { FactoryGirl.create :login_ticket, :expired }

      it 'calls the #invalid_login_ticket method on the listener' do
        listener.should_receive(:invalid_login_ticket).with(kind_of(CASino::LoginTicket))
        processor.process(lt: expired_login_ticket.ticket)
      end
    end

    context 'with a valid login ticket' do
      let(:login_ticket) { FactoryGirl.create :login_ticket }

      context 'with invalid credentials' do
        it 'calls the #invalid_login_credentials method on the listener' do
          listener.should_receive(:invalid_login_credentials).with(kind_of(CASino::LoginTicket))
          processor.process(lt: login_ticket.ticket)
        end
      end

      context 'with valid credentials' do
        let(:service) { 'https://www.example.org' }
        let(:username) { 'testuser' }
        let(:authenticator) { 'static' }
        let(:login_data) { { lt: login_ticket.ticket, username: username, password: 'foobar123', service: service } }

        before(:each) do
          listener.stub(:user_logged_in)
        end

        context 'with rememberMe set' do
          let(:login_data_with_remember_me) { login_data.merge(rememberMe: true) }

          it 'calls the #user_logged_in method on the listener with an expiration date set' do
            listener.should_receive(:user_logged_in).with(/^#{service}\/\?ticket=ST\-/, /^TGC\-/, kind_of(Time))
            processor.process(login_data_with_remember_me)
          end

          it 'creates a long-term ticket-granting ticket' do
            processor.process(login_data_with_remember_me)
            tgt = CASino::TicketGrantingTicket.last
            tgt.long_term.should == true
          end
        end

        context 'with two-factor authentication enabled' do
          let!(:user) { CASino::User.create! username: username, authenticator: authenticator }
          let!(:two_factor_authenticator) { FactoryGirl.create :two_factor_authenticator, user: user }

          it 'calls the `#two_factor_authentication_pending` method on the listener' do
            listener.should_receive(:two_factor_authentication_pending).with(/^TGC\-/)
            processor.process(login_data)
          end
        end

        context 'with a not allowed service' do
          before(:each) do
            FactoryGirl.create :service_rule, :regex, url: '^https://.*'
          end
          let(:service) { 'http://www.example.org/' }

          it 'calls the #service_not_allowed method on the listener' do
            listener.should_receive(:service_not_allowed).with(service)
            processor.process(login_data)
          end
        end

        context 'when all authenticators raise an error' do
          before(:each) do
            CASino::StaticAuthenticator.any_instance.stub(:validate) do
              raise CASino::Authenticator::AuthenticatorError, 'error123'
            end
          end

          it 'calls the #invalid_login_credentials method on the listener' do
            listener.should_receive(:invalid_login_credentials).with(kind_of(CASino::LoginTicket))
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
            end.should change(CASino::TicketGrantingTicket, :count).by(1)
          end

          context 'when the user does not exist yet' do
            it 'generates exactly one user' do
              lambda do
                processor.process(login_data)
              end.should change(CASino::User, :count).by(1)
            end

            it 'sets the users attributes' do
              processor.process(login_data)
              user = CASino::User.last
              user.username.should == username
              user.authenticator.should == authenticator
            end
          end

          context 'when the user already exists' do
            it 'does not regenerate the user' do
              CASino::User.create! username: username, authenticator: authenticator
              lambda do
                processor.process(login_data)
              end.should_not change(CASino::User, :count)
            end

            it 'updates the extra attributes' do
              user = CASino::User.create! username: username, authenticator: authenticator
              lambda do
                processor.process(login_data)
                user.reload
              end.should change(user, :extra_attributes)
            end
          end
        end

        context 'with a service' do
          let(:service) { 'https://www.example.com' }

          it 'calls the #user_logged_in method on the listener' do
            listener.should_receive(:user_logged_in).with(/^#{service}\/\?ticket=ST\-/, /^TGC\-/)
            processor.process(login_data)
          end

          it 'generates a service ticket' do
            lambda do
              processor.process(login_data)
            end.should change(CASino::ServiceTicket, :count).by(1)
          end

          it 'generates a ticket-granting ticket' do
            lambda do
              processor.process(login_data)
            end.should change(CASino::TicketGrantingTicket, :count).by(1)
          end
        end
      end
    end
  end
end
