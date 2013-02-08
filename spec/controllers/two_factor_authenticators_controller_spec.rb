require 'spec_helper'

describe CASino::TwoFactorAuthenticatorsController do
  describe 'GET "new"' do
    it 'calls the process method of the TwoFactorAuthenticatorRegistrator' do
      CASinoCore::Processor::TwoFactorAuthenticatorRegistrator.any_instance.should_receive(:process)
      get :new
    end
  end

  describe 'POST "create"' do
    it 'calls the process method of the TwoFactorAuthenticatorActivator' do
      CASinoCore::Processor::TwoFactorAuthenticatorActivator.any_instance.should_receive(:process) do
        @controller.render nothing: true
      end
      post :create
    end
  end

  describe 'DELETE "destroy"' do
    let(:id) { '123' }
    let(:tgt) { 'TGT-foobar' }
    it 'calls the process method of the TwoFactorAuthenticatorDestroyer processor' do
      request.cookies[:tgt] = tgt
      CASinoCore::Processor::TwoFactorAuthenticatorDestroyer.any_instance.should_receive(:process) do |params, cookies, user_agent|
        params[:id].should == id
        cookies[:tgt].should == tgt
        user_agent.should == request.user_agent
        @controller.render nothing: true
      end
      delete :destroy, id: id
    end
  end
end
