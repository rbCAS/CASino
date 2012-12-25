require 'casino_core/model'
require 'casino_core/settings'
require 'addressable/uri'

class CASinoCore::Model::ProxyTicket < ActiveRecord::Base
  attr_accessible :ticket, :service
  validates :ticket, uniqueness: true
  belongs_to :proxy_granting_ticket
  has_many :proxy_granting_tickets
end
