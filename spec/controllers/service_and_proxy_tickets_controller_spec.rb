require 'spec_helper'

shared_examples_for 'a service ticket validator' do
  include CASino::Engine.routes.url_helpers
  let(:request_options) { params.merge(use_route: :casino) }
  let(:service_ticket) { FactoryGirl.create :service_ticket }
  let(:service) { service_ticket.service }
  let(:parameters) { { service: service, ticket: service_ticket.ticket }}
  let(:params) { parameters }

  render_views

  describe 'GET "serviceValidate"' do
    let(:regex_failure) { /\A\<cas\:serviceResponse.*\n.*authenticationFailure/ }
    let(:regex_success) { /\A\<cas\:serviceResponse.*\n.*authenticationSuccess/ }

    context 'without all required parameters' do
      [:ticket, :service].each do |missing_parameter|
        let(:params) { parameters.except(missing_parameter) }

        context "without '#{missing_parameter}'" do
          it 'answers with the failure text' do
            get validation_action, request_options
            response.body.should =~ regex_failure
          end
        end
      end
    end

    context 'with an unconsumed service ticket' do
      context 'with extra attributes using strings as keys' do
        before(:each) do
          CASino::User.any_instance.stub(:extra_attributes).and_return({ "id" => 1234 })
        end

        it 'includes the extra attributes' do
          get validation_action, request_options
          response.body.should =~ /<cas\:id>1234<\/cas\:id\>/
        end
      end

      context 'with extra attributes using array as value' do
        before(:each) do
          CASino::User.any_instance.stub(:extra_attributes).and_return({ "memberOf" => [ "test", "yolo" ] })
        end

        it 'includes all values' do
          get validation_action, request_options
          response.body.should =~ /<cas\:memberOf>test<\/cas\:memberOf\>/
          response.body.should =~ /<cas\:memberOf>yolo<\/cas\:memberOf\>/
        end
      end

      context 'issued from a long_term ticket-granting ticket' do
        before(:each) do
          service_ticket.ticket_granting_ticket.update_attribute(:long_term, true)
        end

        it 'includes the long-term flag in the answer' do
          get validation_action, request_options
          response.body.should =~ /<cas\:longTermAuthenticationRequestTokenUsed>true<\/cas\:longTermAuthenticationRequestTokenUsed>/
        end
      end

      context 'without renew flag' do
        it 'consumes the service ticket' do
          get validation_action, request_options
          service_ticket.reload.consumed.should == true
        end

        it 'answers with the success text' do
          get validation_action, request_options
          response.body.should =~ regex_success
        end
      end

      context 'with empty query values' do
        let(:service) { "#{service_ticket.service}?" }

        it 'answers with the success text' do
          get validation_action, request_options
          response.body.should =~ regex_success
        end
      end

      context 'with renew flag' do
        let(:params) { parameters.merge renew: 'true' }

        context 'with a service ticket without issued_from_credentials flag' do
          it 'consumes the service ticket' do
            get validation_action, request_options
            service_ticket.reload.consumed.should == true
          end

          it 'answers with the failure text' do
            get validation_action, request_options
            response.body.should =~ regex_failure
          end
        end

        context 'with a service ticket with issued_from_credentials flag' do
          before(:each) do
            service_ticket.issued_from_credentials = true
            service_ticket.save!
          end

          it 'consumes the service ticket' do
            get validation_action, request_options
            service_ticket.reload.consumed.should == true
          end

          it 'answers with the success text' do
            get validation_action, request_options
            response.body.should =~ regex_success
          end
        end
      end

      context 'with proxy-granting ticket callback server' do
        let(:pgt_url) { 'https://www.example.org' }
        let(:params) { parameters.merge pgtUrl: pgt_url }

        before(:each) do
          stub_request(:get, /#{pgt_url}\/\?pgtId=[^&]+&pgtIou=[^&]+/)
        end

        context 'not using https' do
          let(:pgt_url) { 'http://www.example.org' }

          it 'answers with the success text' do
            get validation_action, request_options
            response.body.should =~ regex_success
          end

          it 'does not create a proxy-granting ticket' do
            lambda do
              get validation_action, request_options
            end.should_not change(service_ticket.proxy_granting_tickets, :count)
          end
        end

        it 'answers with the success text' do
          get validation_action, request_options
          response.body.should =~ regex_success
        end

        it 'includes the PGTIOU in the response' do
          get validation_action, request_options
          response.body.should =~ /\<cas\:proxyGrantingTicket\>\n?\s*PGTIOU-.+/
        end

        it 'creates a proxy-granting ticket' do
          lambda do
            get validation_action, request_options
          end.should change(service_ticket.proxy_granting_tickets, :count).by(1)
        end

        it 'contacts the callback server' do
          get validation_action, request_options
          proxy_granting_ticket = CASino::ProxyGrantingTicket.last
          WebMock.should have_requested(:get, 'https://www.example.org').with(query: {
            pgtId: proxy_granting_ticket.ticket,
            pgtIou: proxy_granting_ticket.iou
          })
        end

        context 'when callback server gives an error' do
          before(:each) do
            stub_request(:get, /#{pgt_url}.*/).to_return status: 404
          end

          it 'answers with the success text' do
            get validation_action, request_options
            response.body.should =~ regex_success
          end

          it 'does not create a proxy-granting ticket' do
            lambda do
              get validation_action, request_options
            end.should_not change(service_ticket.proxy_granting_tickets, :count)
          end
        end

        context 'when callback server is unreachable' do
          before(:each) do
            stub_request(:get, /#{pgt_url}.*/).to_raise(Timeout::Error)
          end

          it 'answers with the success text' do
            get validation_action, request_options
            response.body.should =~ regex_success
          end

          it 'does not create a proxy-granting ticket' do
            lambda do
              get validation_action, request_options
            end.should_not change(service_ticket.proxy_granting_tickets, :count)
          end
        end
      end
    end

    context 'with a consumed service ticket' do
      before(:each) do
        service_ticket.update_attribute(:consumed, true)
      end

      it 'answers with the failure text' do
        get validation_action, request_options
        response.body.should =~ regex_failure
      end
    end
  end
end

describe CASino::ServiceTicketsController do
  let(:validation_action) { :service_validate }
  it_behaves_like 'a service ticket validator'
end

describe CASino::ProxyTicketsController do
  let(:validation_action) { :proxy_validate }
  it_behaves_like 'a service ticket validator'
end
