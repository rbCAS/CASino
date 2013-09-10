require 'spec_helper'

describe CASino::TwoFactorAuthenticatorOverviewListener do
  include CASino::Engine.routes.url_helpers
  let(:controller) { Struct.new(:cookies).new(cookies: {}) }
  let(:listener) { described_class.new(controller) }

  describe '#two_factor_authenticators_found' do
    let(:two_factor_authenticators) { [Object.new] }

    it 'assigns the two-factor authenticators' do
      listener.two_factor_authenticators_found(two_factor_authenticators)
      controller.instance_variable_get(:@two_factor_authenticators).should == two_factor_authenticators
    end
  end
end
