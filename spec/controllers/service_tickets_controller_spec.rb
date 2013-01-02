require 'spec_helper'

describe CASino::ServiceTicketsController do
  describe 'GET "validate"' do
    let(:params) { { service: 'https://www.example.com/' } }
    it 'calls the process method of the LegacyValidator' do
      CASinoCore::Processor::LegacyValidator.any_instance.should_receive(:process).with(kind_of(Hash)) do |params|
        params.should == controller.params
        controller.render nothing: true
      end
      get :validate, params
    end
  end

  describe 'GET "serviceValidate"' do
    let(:params) { { service: 'https://www.example.com/' } }
    it 'calls the process method of the LegacyValidator' do
      CASinoCore::Processor::ServiceTicketValidator.any_instance.should_receive(:process).with(kind_of(Hash)) do |params|
        params.should == controller.params
        controller.render nothing: true
      end
      get :service_validate, params
    end
  end
end
