require 'spec_helper'

describe CASino::TwoFactorAuthenticatorRegistratorListener do
  include CASino::Engine.routes.url_helpers
  let(:controller) { Struct.new(:cookies).new(cookies: {}) }
  let(:listener) { described_class.new(controller) }

  before(:each) do
    controller.stub(:redirect_to)
  end

  describe '#user_not_logged_in' do
    it 'redirects to the login page' do
      controller.should_receive(:redirect_to).with(login_path)
      listener.user_not_logged_in
    end
  end

  describe '#two_factor_authenticator_registered' do
    let(:two_factor_authenticator) { Object.new }

    it 'assigns the two-factor authenticator' do
      listener.two_factor_authenticator_registered(two_factor_authenticator)
      controller.instance_variable_get(:@two_factor_authenticator).should == two_factor_authenticator
    end
  end
end
