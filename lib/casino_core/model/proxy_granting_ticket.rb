require 'casino_core/model'

class CASinoCore::Model::ProxyGrantingTicket < ActiveRecord::Base
  attr_accessible :iou, :ticket, :ticket_granting_ticket_id
  validates :ticket, uniqueness: true
  validates :iou, uniqueness: true
  belongs_to :ticket_granting_ticket
end
