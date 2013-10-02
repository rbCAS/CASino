require 'spec_helper'

describe CASino::TwoFactorAuthenticatorsController do
  describe 'GET "new"' do
    it 'calls the process method of the TwoFactorAuthenticatorRegistrator' do
      CASino::TwoFactorAuthenticatorRegistratorProcessor.any_instance.should_receive(:process)
      get :new, use_route: :casino
    end
  end

  describe 'POST "create"' do
    it 'calls the process method of the TwoFactorAuthenticatorActivator' do
      CASino::TwoFactorAuthenticatorActivatorProcessor.any_instance.should_receive(:process) do
        @controller.render nothing: true
      end
      post :create, use_route: :casino
    end
  end

  describe 'DELETE "destroy"' do
    let(:id) { '123' }
    let(:tgt) { 'TGT-foobar' }
    it 'calls the process method of the TwoFactorAuthenticatorDestroyer processor' do
      request.cookies[:tgt] = tgt
      CASino::TwoFactorAuthenticatorDestroyerProcessor.any_instance.should_receive(:process) do |params, cookies, user_agent|
        params[:id].should == id
        cookies[:tgt].should == tgt
        user_agent.should == request.user_agent
        @controller.render nothing: true
      end
      delete :destroy, id:id, use_route: :casino
    end
  end
end
