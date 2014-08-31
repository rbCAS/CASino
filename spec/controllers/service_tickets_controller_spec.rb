describe CASino::ServiceTicketsController do
  describe 'GET "validate"' do
    let(:request_options) { params.merge(use_route: :casino) }
    let(:service_ticket) { FactoryGirl.create :service_ticket }
    let(:service) { service_ticket.service }
    let(:parameters) { { service: service, ticket: service_ticket.ticket }}
    let(:params) { parameters }
    let(:username) { service_ticket.ticket_granting_ticket.user.username }
    let(:response_text_success) { "yes\n#{username}\n" }
    let(:response_text_failure) { "no\n\n" }

    render_views

    context 'with an unconsumed service ticket' do
      context 'without renew flag' do
        it 'consumes the service ticket' do
          get :validate, request_options
          service_ticket.reload.consumed.should == true
        end

        it 'answers with the expected response text' do
          get :validate, request_options
          response.body.should == response_text_success
        end
      end

      context 'with renew flag' do
        let(:params) { parameters.merge renew: 'true' }

        context 'with a service ticket without issued_from_credentials flag' do
          it 'consumes the service ticket' do
            get :validate, request_options
            service_ticket.reload.consumed.should == true
          end

          it 'answers with the expected response text' do
            get :validate, request_options
            response.body.should == response_text_failure
          end
        end

        context 'with a service ticket with issued_from_credentials flag' do
          before(:each) do
            service_ticket.update_attribute(:issued_from_credentials, true)
          end

          it 'consumes the service ticket' do
            get :validate, request_options
            service_ticket.reload.consumed.should == true
          end

          it 'answers with the expected response text' do
            get :validate, request_options
            response.body.should == response_text_success
          end
        end
      end
    end

    context 'with a consumed service ticket' do
      before(:each) do
        service_ticket.update_attribute(:consumed, true)
      end

      it 'answers with the expected response text' do
        get :validate, request_options
        response.body.should == response_text_failure
      end
    end
  end
end
