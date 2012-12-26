require 'spec_helper'

describe ProxyTicketsController do
  describe 'GET "serviceValidate"' do
    let(:params) { { service: 'https://www.example.com/' } }
    it 'calls the process method of the ProxyTicketValidator' do
      CASinoCore::Processor::ProxyTicketValidator.any_instance.should_receive(:process).with(kind_of(Hash)) do |params|
        params.should == controller.params
        controller.render nothing: true
      end
      get :proxy_validate, params
    end
  end
end
