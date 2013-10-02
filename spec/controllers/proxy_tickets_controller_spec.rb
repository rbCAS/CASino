require 'spec_helper'

describe CASino::ProxyTicketsController do
  describe 'GET "serviceValidate"' do
    let(:params) { { service: 'https://www.example.com/', use_route: :casino } }
    it 'calls the process method of the ProxyTicketValidator' do
      CASino::ProxyTicketValidatorProcessor.any_instance.should_receive(:process).with(kind_of(Hash)) do |params|
        params.should == controller.params
        controller.render nothing: true
      end
      get :proxy_validate, params
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
