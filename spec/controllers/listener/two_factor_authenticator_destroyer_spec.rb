require 'spec_helper'

describe CASino::TwoFactorAuthenticatorDestroyerListener do
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

  describe '#two_factor_authenticator_destroyed' do
    it 'redirects to the session overview' do
      controller.should_receive(:redirect_to).with(sessions_path)
      listener.two_factor_authenticator_destroyed
    end

    it 'adds a notice' do
      listener.two_factor_authenticator_destroyed
      flash[:notice].should == I18n.t('two_factor_authenticators.successfully_deleted')
    end
  end

  describe '#invalid_two_factor_authenticator' do
    it 'redirects to the session overview' do
      controller.should_receive(:redirect_to).with(sessions_path)
      listener.invalid_two_factor_authenticator
    end
  end
end
