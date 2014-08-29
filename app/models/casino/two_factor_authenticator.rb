
class CASino::TwoFactorAuthenticator < ActiveRecord::Base
  belongs_to :user

  scope :active, -> { where(active: true) }

  def self.cleanup
    self.delete_all(['(created_at < ?) AND active = ?', self.lifetime.ago, false])
  end

  def self.lifetime
    CASino.config.two_factor_authenticator[:lifetime_inactive].seconds
  end

  def expired?
    !self.active? && (Time.now - (self.created_at || Time.now)) > self.class.lifetime
  end
end
