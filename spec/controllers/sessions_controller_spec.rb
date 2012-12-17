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
      CASinoCore::Processor::Logout.any_instance.should_receive(:process)
      get :logout
    end
  end
end
