require 'spec_helper'

describe CASino::AuthTokensController do
  include CASino::Engine.routes.url_helpers

  let(:params) { { } }
  let(:request_options) { params.merge(use_route: :casino) }

  before(:each) do
    CASino::AuthTokenValidationService.any_instance.stub(:validation_result).and_return(validation_result)
  end

  describe 'GET "authTokenLogin"' do
    context 'with invalid data' do
      let(:validation_result) { false }
      let(:service) { 'http://www.example.org/' }
      let(:params) { { service: service } }

      it 'redirects to the login' do
        get :login, request_options
        response.should redirect_to(login_path(service: service))
      end
    end

    context 'with valid data' do
      let(:validation_result) { { authenticator: 'icanhaz', user_data: { username: 'cheezeburger' } } }

      context 'with a not allowed service' do
        before(:each) do
          FactoryGirl.create :service_rule, :regex, url: '^https://.*'
        end

        let(:service) { 'http://www.example.org/' }
        let(:params) { { service: service } }

        it 'renders the service_not_allowed template' do
          get :login, request_options
          response.should render_template(:service_not_allowed)
        end
      end

      context 'with a service' do
        let(:service) { 'http://www.example.org/' }
        let(:params) { { service: service } }

        it 'redirects to the service' do
          get :login, request_options
          response.location.should =~ /^#{Regexp.escape service}\?ticket=ST-/
        end

        it 'generates a service ticket' do
          lambda do
            get :login, request_options
          end.should change(CASino::ServiceTicket, :count).by(1)
        end
      end

      it 'creates a cookie' do
        get :login, request_options
        response.cookies['tgt'].should_not be_nil
      end

      it 'generates a ticket-granting ticket' do
        lambda do
          get :login, request_options
        end.should change(CASino::TicketGrantingTicket, :count).by(1)
      end

      it 'redirects to the session overview' do
        get :login, request_options
        response.should redirect_to(sessions_path)
      end
    end
  end
end
