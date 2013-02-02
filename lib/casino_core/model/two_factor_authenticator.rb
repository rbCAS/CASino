require 'casino_core/model'

class CASinoCore::Model::TwoFactorAuthenticator < ActiveRecord::Base
  attr_accessible :secret

  belongs_to :user
end
