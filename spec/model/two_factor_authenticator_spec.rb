require 'spec_helper'

describe CASino::TwoFactorAuthenticator do
  describe '.cleanup' do
    it 'deletes expired inactive two-factor authenticators' do
      authenticator = FactoryGirl.create :two_factor_authenticator, :inactive
      authenticator.created_at = 10.hours.ago
      authenticator.save!
      lambda do
        described_class.cleanup
      end.should change(described_class, :count).by(-1)
    end

    it 'does not delete not expired inactive two-factor authenticators' do
      authenticator = FactoryGirl.create :two_factor_authenticator, :inactive
      authenticator.created_at = (CASino.config.two_factor_authenticator[:lifetime_inactive].seconds - 5).ago
      lambda do
        described_class.cleanup
      end.should_not change(described_class, :count)
    end

    it 'does not delete active two-factor authenticators' do
      authenticator = FactoryGirl.create :two_factor_authenticator
      authenticator.created_at = 10.hours.ago
      authenticator.save!
      lambda do
        described_class.cleanup
      end.should_not change(described_class, :count)
    end
  end
end
