require 'casino_core/model'

class CASinoCore::Model::ProxyGrantingTicket < ActiveRecord::Base
  attr_accessible :iou, :ticket, :service_ticket_id
  validates :ticket, uniqueness: true
  validates :iou, uniqueness: true
  belongs_to :service_ticket
  has_many :proxy_tickets
end
