require 'spec_helper'

describe CASino::ProxyTicketsController do
  describe 'GET "proxyValidate"' do
    let(:request_options) { params.merge(use_route: :casino) }
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
    let(:params) { { service: 'https://www.example.com/', use_route: :casino } }
    it 'calls the process method of the ProxyTicketProvider' do
      CASino::ProxyTicketProviderProcessor.any_instance.should_receive(:process).with(kind_of(Hash)) do |params|
        params.should == controller.params
        controller.render nothing: true
      end
      get :create, params
    end
  end
end
