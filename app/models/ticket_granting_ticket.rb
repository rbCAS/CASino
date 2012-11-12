class TicketGrantingTicket < ActiveRecord::Base
  attr_accessible :ticket, :username
  validates :ticket, uniqueness: true
end
