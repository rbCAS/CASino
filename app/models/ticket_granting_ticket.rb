class TicketGrantingTicket < ActiveRecord::Base
  attr_accessible :ticket, :username, :user_agent
  validates :ticket, uniqueness: true
end
