class ServiceTicket < ActiveRecord::Base
  attr_accessible :ticket, :service, :ticket_granting_ticket_id
  validates :ticket, uniqueness: true
  belongs_to :ticket_granting_ticket
end
