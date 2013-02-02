require 'casino_core/model'

class CASinoCore::Model::User < ActiveRecord::Base
  attr_accessible :authenticator, :username, :extra_attributes
  serialize :extra_attributes, Hash

  has_many :ticket_granting_tickets
end
