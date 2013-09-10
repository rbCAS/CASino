require 'spec_helper'

describe CASino::TwoFactorAuthenticatorActivatorListener do
  include CASino::Engine.routes.url_helpers
  let(:controller) { Struct.new(:cookies).new(cookies: {}) }
  let(:listener) { described_class.new(controller) }
  let(:flash) { ActionDispatch::Flash::FlashHash.new }

  before(:each) do
    controller.stub(:redirect_to)
    controller.stub(:render)
    controller.stub(:flash).and_return(flash)
  end

  describe '#user_not_logged_in' do
    it 'redirects to the login page' do
      controller.should_receive(:redirect_to).with(login_path)
      listener.user_not_logged_in
    end
  end

  describe '#two_factor_authenticator_activated' do
    it 'redirects to the session overview' do
      controller.should_receive(:redirect_to).with(sessions_path)
      listener.two_factor_authenticator_activated
    end

    it 'adds a notice' do
      listener.two_factor_authenticator_activated
      flash[:notice].should == I18n.t('two_factor_authenticators.successfully_activated')
    end
  end

  describe '#invalid_two_factor_authenticator' do
    it 'redirects to the two-factor authenticator new page' do
      controller.should_receive(:redirect_to).with(new_two_factor_authenticator_path)
      listener.invalid_two_factor_authenticator
    end

    it 'adds a error message' do
      listener.invalid_two_factor_authenticator
      flash[:error].should == I18n.t('two_factor_authenticators.invalid_two_factor_authenticator')
    end
  end

  describe '#invalid_one_time_password' do
    let(:two_factor_authenticator) { Object.new }

    it 'rerenders the new page' do
      controller.should_receive(:render).with('new')
      listener.invalid_one_time_password(two_factor_authenticator)
    end

    it 'adds a error message' do
      listener.invalid_one_time_password(two_factor_authenticator)
      flash[:error].should == I18n.t('two_factor_authenticators.invalid_one_time_password')
    end

    it 'assigns the two-factor authenticator' do
      listener.invalid_one_time_password(two_factor_authenticator)
      controller.instance_variable_get(:@two_factor_authenticator).should == two_factor_authenticator
    end
  end
end
