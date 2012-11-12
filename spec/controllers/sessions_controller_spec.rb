require 'spec_helper'

describe SessionsController do
  render_views
  
  describe 'GET "new"' do
    before(:each) do
      get :new
    end

    it 'should be successful' do
      response.should be_success
    end

    it 'should have the right heading' do
      response.should have_selector('h1', content: 'Login')
    end
  end
end
