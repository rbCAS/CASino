require 'casino_core/model'

class CASinoCore::Model::TwoFactorAuthenticator < ActiveRecord::Base
  attr_accessible :secret

  belongs_to :user

  def self.cleanup
    self.delete_all(['(created_at < ?) AND active = ?', CASinoCore::Settings.two_factor_authenticator[:lifetime_inactive].seconds.ago, false])
  end
end
