require 'spec_helper'

describe CASino::ProxyTicketsController do
  let(:request_options) { params.merge(use_route: :casino) }

  describe 'GET "proxyValidate"' do
    let(:proxy_ticket) { FactoryGirl.create :proxy_ticket }
    let(:service) { proxy_ticket.service }
    let(:parameters) { { service: service, ticket: proxy_ticket.ticket }}
    let(:params) { parameters }
    let(:regex_success) { /\A<cas:serviceResponse.*\n.*authenticationSuccess/ }
    let(:regex_failure) { /\A\<cas\:serviceResponse.*\n.*authenticationFailure/ }

    render_views

    context 'with an unconsumed proxy ticket' do
      let(:regex_proxy) { /<cas:proxies>\s*<cas:proxy>#{proxy_ticket.proxy_granting_ticket.pgt_url}<\/cas:proxy>\s*<\/cas:proxies>/ }

      it 'answers with the success text' do
        get :proxy_validate, request_options
        response.body.should =~ regex_success
      end

      it 'includes the proxy in the response' do
        get :proxy_validate, request_options
        response.body.should =~ regex_proxy
      end

      context 'with an expired proxy ticket' do
        before(:each) do
          CASino::ProxyTicket.any_instance.stub(:expired?).and_return(true)
        end

        it 'answers with the failure text' do
          get :proxy_validate, request_options
          response.body.should =~ regex_failure
        end
      end

      context 'with an other service' do
        let(:params) { parameters.merge(service: 'this_is_another_service') }

        it 'answers with the failure text' do
          get :proxy_validate, request_options
          response.body.should =~ regex_failure
        end
      end

      context 'without an existing ticket' do
        let(:params) { { ticket: 'PT-1234', service: 'https://www.example.com/' } }

        it 'answers with the failure text' do
          get :proxy_validate, request_options
          response.body.should =~ regex_failure
        end
      end
    end
  end

  describe 'GET "proxy"' do
    let(:parameters) { { targetService: 'this_does_not_have_to_be_a_url' } }
    let(:params) { parameters }
    let(:regex_success) { /\A<cas:serviceResponse.*\n.*proxySuccess/ }
    let(:regex_failure) { /\A\<cas\:serviceResponse.*\n.*proxyFailure/ }

    context 'without proxy-granting ticket' do
      it 'answers with the failure text' do
        get :create, request_options
        response.body.should =~ regex_failure
      end

      it 'does not create a proxy ticket' do
        lambda do
          get :create, request_options
        end.should_not change(CASino::ProxyTicket, :count)
      end
    end

    context 'with a not-existing proxy-granting ticket' do
      let(:params) { parameters.merge(pgt: 'PGT-123453789') }

      it 'answers with the failure text' do
        get :create, request_options
        response.body.should =~ regex_failure
      end

      it 'does not create a proxy ticket' do
        lambda do
          get :create, request_options
        end.should_not change(CASino::ProxyTicket, :count)
      end
    end

    context 'with a proxy-granting ticket' do
      let(:proxy_granting_ticket) { FactoryGirl.create :proxy_granting_ticket }
      let(:params) { parameters.merge(pgt: proxy_granting_ticket.ticket) }

      it 'answers with the success text' do
        get :create, request_options
        response.body.should =~ regex_success
      end

      it 'does create a proxy ticket' do
        lambda do
          get :create, request_options
        end.should change(proxy_granting_ticket.proxy_tickets, :count).by(1)
      end

      it 'includes the proxy ticket in the response' do
        get :create, request_options
        proxy_ticket = CASino::ProxyTicket.last
        response.body.should =~ /<cas:proxyTicket>#{proxy_ticket.ticket}<\/cas:proxyTicket>/
      end

      context 'without a targetService' do
        let(:params) { parameters.merge(pgt: proxy_granting_ticket.ticket, targetService: nil) }

        it 'answers with the failure text' do
          get :create, request_options
          response.body.should =~ regex_failure
        end

        it 'does not create a proxy ticket' do
          lambda do
            get :create, request_options
          end.should_not change(CASino::ProxyTicket, :count)
        end
      end
    end
  end
end
