require 'spec_helper'

describe SessionsController do
  render_views
  
  describe 'GET "new"' do
    it 'should be successful' do
      get :new
      response.should be_success
    end

    it 'should have the right heading' do
      get :new
      response.should have_selector('h1', content: 'Login')
    end

    it 'should generate a login ticket' do
      lambda do
        get :new
      end.should change(LoginTicket, :count).by(1)
    end
  end

  describe 'POST "create"' do
    describe 'without a valid login ticket' do
      it 'should redirect to the login page' do
        post :create
        response.should redirect_to(login_path)
      end

      it 'should have a flash message' do
        post :create
        flash[:error].should =~ /try again/
      end
    end
  end
end
