require 'spec_helper'

describe SessionsController do
  describe 'GET "new"' do
    it 'calls the process method of the LoginCredentialRequestor' do
      CASinoCore::Processor::LoginCredentialRequestor.any_instance.should_receive(:process)
      get :new
    end
  end

  describe 'POST "create"' do
    it 'calls the process method of the LoginCredentialAcceptor' do
      CASinoCore::Processor::LoginCredentialAcceptor.any_instance.should_receive(:process) do
        @controller.render nothing: true
      end
      post :create
    end
  end

  describe 'GET "logout"' do
    it 'calls the process method of the Logout processor' do
      CASinoCore::Processor::Logout.any_instance.should_receive(:process) do |params, cookies, user_agent|
        params.should == controller.params
        cookies.should == controller.cookies
        user_agent.should == request.user_agent
      end
      get :logout
    end
  end

  describe 'GET "index"' do
    it 'calls the process method of the SessionOverview processor' do
      CASinoCore::Processor::SessionOverview.any_instance.should_receive(:process)
      get :index
    end
  end

  describe 'DELETE "destroy"' do
    let(:id) { '123' }
    let(:tgt) { 'TGT-foobar' }
    it 'calls the process method of the SessionOverview processor' do
      request.cookies[:tgt] = tgt
      CASinoCore::Processor::SessionDestroyer.any_instance.should_receive(:process) do |params, cookies, user_agent|
        params[:id].should == id
        cookies[:tgt].should == tgt
        user_agent.should == request.user_agent
        @controller.render nothing: true
      end
      delete :destroy, id: id
    end
  end
end
