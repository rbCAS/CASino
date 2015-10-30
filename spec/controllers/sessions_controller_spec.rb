require 'spec_helper'

describe CASino::SessionsController do
  include CASino::Engine.routes.url_helpers
  let(:params) { { } }
  let(:request_options) { params.merge(use_route: :casino) }
  let(:user_agent) { 'YOLOBrowser 420.00'}

  before(:each) do
    request.user_agent = user_agent
  end

  describe 'GET "new"' do
    context 'with a not allowed service' do
      before(:each) do
        FactoryGirl.create :service_rule, :regex, url: '^https://.*'
      end

      let(:service) { 'http://www.example.org/' }
      let(:params) { { service: service } }

      it 'renders the service_not_allowed template' do
        get :new, request_options
        response.should render_template(:service_not_allowed)
      end
    end

    context 'when logged out' do
      it 'renders the new template' do
        get :new, request_options
        response.should render_template(:new)
      end

      context 'with gateway parameter' do
        context 'with a service' do
          let(:service) { 'http://example.com/' }
          let(:params) { { service: service, gateway: 'true' } }

          it 'redirects to the service' do
            get :new, request_options
            response.should redirect_to(service)
          end
        end

        context 'without a service' do
          let(:params) { { gateway: 'true' } }

          it 'renders the new template' do
            get :new, request_options
            response.should render_template(:new)
          end
        end
      end
    end

    context 'when logged in' do
      let(:ticket_granting_ticket) { FactoryGirl.create :ticket_granting_ticket }

      before(:each) do
        sign_in(ticket_granting_ticket)
      end

      context 'when two-factor authentication is pending' do
        let(:ticket_granting_ticket) { FactoryGirl.create :ticket_granting_ticket, :awaiting_two_factor_authentication }

        it 'renders the new template' do
          get :new, request_options
          response.should render_template(:new)
        end
      end

      context 'when ticket-granting ticket expired' do
        before(:each) do
          ticket_granting_ticket.created_at = 25.hours.ago
          ticket_granting_ticket.save!
        end

        it 'renders the new template' do
          get :new, request_options
          response.should render_template(:new)
        end
      end

      context 'with a service' do
        let(:service) { 'http://example.com/' }
        let(:params) { { service: service } }

        it 'redirects to the service' do
          get :new, request_options
          response.location.should =~ /^#{Regexp.escape service}\?ticket=ST-/
        end

        it 'generates a service ticket' do
          lambda do
            get :new, request_options
          end.should change(CASino::ServiceTicket, :count).by(1)
        end

        it 'does not set the issued_from_credentials flag on the service ticket' do
          get :new, request_options
          CASino::ServiceTicket.last.should_not be_issued_from_credentials
        end

        context 'with renew parameter' do
          it 'renders the new template' do
            get :new, request_options.merge(renew: 'true')
            response.should render_template(:new)
          end
        end
      end

      context 'with a service with nested attributes' do
        let(:service) { 'http://example.com/?a%5B%5D=test&a%5B%5D=example' }
        let(:params) { { service: service } }

        it 'does not remove the attributes' do
          get :new, request_options
          response.location.should =~ /^#{Regexp.escape service}&ticket=ST-/
        end
      end

      context 'with a broken service' do
        let(:service) { '%3Atest' }
        let(:params) { { service: service } }

        it 'redirects to the session overview' do
          get :new, request_options
          response.should redirect_to(sessions_path)
        end
      end

      context 'without a service' do
        it 'redirects to the session overview' do
          get :new, request_options
          response.should redirect_to(sessions_path)
        end

        it 'does not generate a service ticket' do
          lambda do
            get :new, request_options
          end.should change(CASino::ServiceTicket, :count).by(0)
        end

        context 'with a changed browser' do
          let(:user_agent) { 'FooBar 1.0' }

          before(:each) do
            request.user_agent = user_agent
          end

          it 'renders the new template' do
            get :new, request_options
            response.should render_template(:new)
          end
        end
      end
    end

    context 'with an unsupported format' do
      it 'sets the status code to 406' do
        get :new, use_route: :casino, format: :xml
        response.status.should == 406
      end
    end
  end

  describe 'POST "create"' do
    context 'without a valid login ticket' do
      it 'renders the new template' do
        post :create, request_options
        response.should render_template(:new)
      end
    end

    context 'with an expired login ticket' do
      let(:expired_login_ticket) { FactoryGirl.create :login_ticket, :expired }
      let(:params) { { lt: expired_login_ticket.ticket }}

      it 'renders the new template' do
        post :create, request_options
        response.should render_template(:new)
      end
    end

    context 'with a valid login ticket' do
      let(:login_ticket) { FactoryGirl.create :login_ticket }
      let(:params) { { lt: login_ticket.ticket }}

      context 'with invalid credentials' do
        it 'renders the new template' do
          post :create, request_options
          response.should render_template(:new)
        end
      end

      context 'with valid credentials' do
        let(:service) { 'https://www.example.org' }
        let(:username) { 'testuser' }
        let(:authenticator) { 'static' }
        let(:params) { { lt: login_ticket.ticket, username: username, password: 'foobar123', service: service } }

        it 'creates a cookie' do
          post :create, request_options
          response.cookies['tgt'].should_not be_nil
        end

        it 'saves user_ip' do
          post :create, request_options
          tgt = CASino::TicketGrantingTicket.last
          tgt.user_ip.should == '0.0.0.0'
        end

        context 'with rememberMe set' do
          let(:cookie_jar) { HashWithIndifferentAccess.new }

          before(:each) do
            params[:rememberMe] = true
            controller.stub(:cookies).and_return(cookie_jar)
          end

          it 'creates a cookie with an expiration date set' do
            post :create, request_options
            cookie_jar['tgt']['expires'].should be_kind_of(Time)
          end

          it 'creates a long-term ticket-granting ticket' do
            post :create, request_options
            tgt = CASino::TicketGrantingTicket.last
            tgt.long_term.should == true
          end
        end

        context 'with two-factor authentication enabled' do
          let!(:user) { CASino::User.create! username: username, authenticator: authenticator }
          let!(:two_factor_authenticator) { FactoryGirl.create :two_factor_authenticator, user: user }

          it 'renders the validate_otp template' do
            post :create, request_options
            response.should render_template(:validate_otp)
          end
        end

        context 'with a not allowed service' do
          before(:each) do
            FactoryGirl.create :service_rule, :regex, url: '^https://.*'
          end
          let(:service) { 'http://www.example.org/' }

          it 'renders the service_not_allowed template' do
            post :create, request_options
            response.should render_template(:service_not_allowed)
          end
        end

        context 'when all authenticators raise an error' do
          before(:each) do
            CASino::StaticAuthenticator.any_instance.stub(:validate) do
              raise CASino::Authenticator::AuthenticatorError, 'error123'
            end
          end

          it 'renders the new template' do
            post :create, request_options
            response.should render_template(:new)
          end
        end

        context 'without a service' do
          let(:service) { nil }

          it 'redirects to the session overview' do
            post :create, request_options
            response.should redirect_to(sessions_path)
          end

          it 'generates a ticket-granting ticket' do
            lambda do
              post :create, request_options
            end.should change(CASino::TicketGrantingTicket, :count).by(1)
          end

          context 'when the user does not exist yet' do
            it 'generates exactly one user' do
              lambda do
                post :create, request_options
              end.should change(CASino::User, :count).by(1)
            end

            it 'sets the users attributes' do
              post :create, request_options
              user = CASino::User.last
              user.username.should == username
              user.authenticator.should == authenticator
            end
          end

          context 'when the user already exists' do
            let!(:user) { CASino::User.create! username: username, authenticator: authenticator }

            it 'does not regenerate the user' do
              lambda do
                post :create, request_options
              end.should_not change(CASino::User, :count)
            end

            it 'updates the extra attributes' do
              lambda do
                post :create, request_options
                user.reload
              end.should change(user, :extra_attributes)
            end
          end
        end

        context 'with a service' do
          let(:service) { 'https://www.example.com' }

          it 'redirects to the service' do
            post :create, request_options
            response.location.should =~ /^#{Regexp.escape service}\/\?ticket=ST-/
          end

          it 'generates a service ticket' do
            lambda do
              post :create, request_options
            end.should change(CASino::ServiceTicket, :count).by(1)
          end

          it 'does set the issued_from_credentials flag on the service ticket' do
            post :create, request_options
            CASino::ServiceTicket.last.should be_issued_from_credentials
          end

          it 'generates a ticket-granting ticket' do
            lambda do
              post :create, request_options
            end.should change(CASino::TicketGrantingTicket, :count).by(1)
          end
        end
      end
    end
  end

  describe 'POST "validate_otp"' do
    context 'with an existing ticket-granting ticket' do
      let(:ticket_granting_ticket) { FactoryGirl.create :ticket_granting_ticket, :awaiting_two_factor_authentication }
      let(:user) { ticket_granting_ticket.user }
      let(:tgt) { ticket_granting_ticket.ticket }
      let(:user_agent) { ticket_granting_ticket.user_agent }
      let(:otp) { '123456' }
      let(:service) { 'http://www.example.com/testing' }
      let(:params) { { tgt: tgt, otp: otp, service: service }}

      context 'with an active authenticator' do
        let!(:two_factor_authenticator) { FactoryGirl.create :two_factor_authenticator, user: user }

        context 'with a valid OTP' do
          before(:each) do
            ROTP::TOTP.any_instance.should_receive(:verify_with_drift).with(otp, 30).and_return(true)
          end

          it 'redirects to the service' do
            post :validate_otp, request_options
            response.location.should =~ /^#{Regexp.escape service}\?ticket=ST-/
          end

          it 'does activate the ticket-granting ticket' do
            post :validate_otp, request_options
            ticket_granting_ticket.reload.should_not be_awaiting_two_factor_authentication
          end

          context 'with a long-term ticket-granting ticket' do
            let(:cookie_jar) { HashWithIndifferentAccess.new }

            before(:each) do
              ticket_granting_ticket.update_attributes! long_term: true
              controller.stub(:cookies).and_return(cookie_jar)
            end

            it 'creates a cookie with an expiration date set' do
              post :validate_otp, request_options
              cookie_jar['tgt']['expires'].should be_kind_of(Time)
            end
          end

          context 'with a not allowed service' do
            before(:each) do
              FactoryGirl.create :service_rule, :regex, url: '^https://.*'
            end
            let(:service) { 'http://www.example.org/' }

            it 'renders the service_not_allowed template' do
              post :validate_otp, request_options
              response.should render_template(:service_not_allowed)
            end
          end
        end

        context 'with an invalid OTP' do
          before(:each) do
            ROTP::TOTP.any_instance.should_receive(:verify_with_drift).with(otp, 30).and_return(false)
          end

          it 'renders the validate_otp template' do
            post :validate_otp, request_options
            response.should render_template(:validate_otp)
          end

          it 'does not activate the ticket-granting ticket' do
            post :validate_otp, request_options
            ticket_granting_ticket.reload.should be_awaiting_two_factor_authentication
          end
        end
      end
    end

    context 'without a ticket-granting ticket' do
      it 'redirects to the login page' do
        post :validate_otp, request_options
        response.should redirect_to(login_path)
      end
    end
  end

  describe 'GET "logout"' do
    let(:url) { nil }
    let(:params) { { :url => url } }

    context 'with an existing ticket-granting ticket' do
      let(:ticket_granting_ticket) { FactoryGirl.create :ticket_granting_ticket }

      before(:each) do
        sign_in(ticket_granting_ticket)
      end

      it 'deletes the ticket-granting ticket' do
        get :logout, request_options
        CASino::TicketGrantingTicket.where(id: ticket_granting_ticket.id).first.should == nil
      end

      it 'renders the logout template' do
        get :logout, request_options
        response.should render_template(:logout)
      end

      context 'with an URL' do
        let(:url) { 'http://www.example.com' }

        it 'assigns the URL' do
          get :logout, request_options
          assigns(:url).should == url
        end
      end

      context 'with a service' do
        let(:params) { { :service => url } }
        let(:url) { 'http://www.example.org' }

        context 'when whitelisted' do
          it 'redirects to the service' do
            get :logout, request_options
            response.should redirect_to(url)
          end
        end

        context 'when not whitelisted' do
          before(:each) do
            FactoryGirl.create :service_rule, :regex, url: '^https://.*'
          end

          it 'renders the logout template' do
            get :logout, request_options
            response.should render_template(:logout)
          end

          it 'does not assign the URL' do
            get :logout, request_options
            assigns(:url).should be_nil
          end
        end
      end
    end

    context 'without a ticket-granting ticket' do
      it 'renders the logout template' do
        get :logout, request_options
        response.should render_template(:logout)
      end
    end
  end

  describe 'GET "index"' do
    context 'with an existing ticket-granting ticket' do
      before(:each) do
        sign_in(ticket_granting_ticket)
      end

      describe 'two-factor authenticator settings' do
        let(:ticket_granting_ticket) { FactoryGirl.create :ticket_granting_ticket }
        let(:user) { ticket_granting_ticket.user }

        context 'without a two-factor authenticator registered' do
          it 'does not assign any two-factor authenticators' do
            get :index, request_options
            assigns(:two_factor_authenticators).should == []
          end
        end

        context 'with an inactive two-factor authenticator' do
          let!(:two_factor_authenticator) { FactoryGirl.create :two_factor_authenticator, :inactive, user: user }

          it 'does not assign any two-factor authenticators' do
            get :index, request_options
            assigns(:two_factor_authenticators).should == []
          end
        end

        context 'with a two-factor authenticator registered' do
          let(:two_factor_authenticator) { FactoryGirl.create :two_factor_authenticator, user: user }
          let!(:other_two_factor_authenticator) { FactoryGirl.create :two_factor_authenticator }

          it 'does assign the two-factor authenticator' do
            get :index, request_options
            assigns(:two_factor_authenticators).should == [two_factor_authenticator]
          end
        end
      end

      describe 'sessions overview' do
        let!(:other_ticket_granting_ticket) { FactoryGirl.create :ticket_granting_ticket }
        let(:user) { other_ticket_granting_ticket.user }

        context 'as user owning the other ticket granting ticket' do
          let(:ticket_granting_ticket) { FactoryGirl.create :ticket_granting_ticket, user: user }

          it 'assigns both ticket granting tickets' do
            get :index, request_options
            assigns(:ticket_granting_tickets).should == [ticket_granting_ticket, other_ticket_granting_ticket]
          end
        end

        context 'with a ticket-granting ticket with same username but different authenticator' do
          let(:ticket_granting_ticket) { FactoryGirl.create :ticket_granting_ticket }
          let(:tgt) { ticket_granting_ticket.ticket }

          it 'does not assign the other ticket granting ticket' do
            get :index, request_options
            assigns(:ticket_granting_tickets).should == [ticket_granting_ticket]
          end
        end
      end
    end

    context 'without a ticket-granting ticket' do
      it 'redirects to the login page' do
        get :index, request_options
        response.should redirect_to(login_path)
      end
    end
  end

  describe 'DELETE "destroy"' do
    let(:owner_ticket_granting_ticket) { FactoryGirl.create :ticket_granting_ticket }
    let(:user) { owner_ticket_granting_ticket.user }

    before(:each) do
      sign_in(owner_ticket_granting_ticket)
    end

    context 'with an existing ticket-granting ticket' do
      let!(:ticket_granting_ticket) { FactoryGirl.create :ticket_granting_ticket, user: user }
      let(:service_ticket) { FactoryGirl.create :service_ticket, ticket_granting_ticket: ticket_granting_ticket }
      let(:consumed_service_ticket) { FactoryGirl.create :service_ticket, :consumed, ticket_granting_ticket: ticket_granting_ticket }
      let(:params) { { id: ticket_granting_ticket.id } }

      it 'deletes exactly one ticket-granting ticket' do
        lambda do
          delete :destroy, request_options
        end.should change(CASino::TicketGrantingTicket, :count).by(-1)
      end

      it 'deletes the ticket-granting ticket' do
        delete :destroy, request_options
        CASino::TicketGrantingTicket.where(id: params[:id]).length.should == 0
      end

      it 'redirects to the session overview' do
        delete :destroy, request_options
        response.should redirect_to(sessions_path)
      end
    end

    context 'with an invalid ticket-granting ticket' do
      let(:params) { { id: 99999 } }
      it 'does not delete a ticket-granting ticket' do
        lambda do
          delete :destroy, request_options
        end.should_not change(CASino::TicketGrantingTicket, :count)
      end

      it 'redirects to the session overview' do
        delete :destroy, request_options
        response.should redirect_to(sessions_path)
      end
    end

    context 'when trying to delete ticket-granting ticket of another user' do
      let!(:ticket_granting_ticket) { FactoryGirl.create :ticket_granting_ticket }
      let(:params) { { id: ticket_granting_ticket.id } }

      it 'does not delete a ticket-granting ticket' do
        lambda do
          delete :destroy, request_options
        end.should_not change(CASino::TicketGrantingTicket, :count)
      end

      it 'redirects to the session overview' do
        delete :destroy, request_options
        response.should redirect_to(sessions_path)
      end
    end
  end

  describe 'GET "destroy_others"' do
    let(:url) { nil }
    let(:params) { { :service => url } }

    context 'with an existing ticket-granting ticket' do
      let(:user) { FactoryGirl.create :user }
      let!(:other_users_ticket_granting_tickets) { FactoryGirl.create_list :ticket_granting_ticket, 3 }
      let!(:other_ticket_granting_tickets) { FactoryGirl.create_list :ticket_granting_ticket, 3, user: user }
      let!(:ticket_granting_ticket) { FactoryGirl.create :ticket_granting_ticket, user: user }

      before(:each) do
        sign_in(ticket_granting_ticket)
      end

      it 'deletes all other ticket-granting tickets' do
        lambda do
          get :destroy_others, request_options
        end.should change(CASino::TicketGrantingTicket, :count).by(-3)
      end

      it 'redirects to the session overview' do
        get :destroy_others, request_options
        response.should redirect_to(sessions_path)
      end

      context 'with an URL' do
        let(:url) { 'http://www.example.com' }

        it 'redirects to the service' do
          get :destroy_others, request_options
          response.should redirect_to(url)
        end
      end
    end

    context 'without a ticket-granting ticket' do
      context 'with an URL' do
        let(:url) { 'http://www.example.com' }

        it 'redirects to the service' do
          get :destroy_others, request_options
          response.should redirect_to(url)
        end
      end
    end
  end
end
