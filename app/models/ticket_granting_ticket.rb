class TicketGrantingTicket < ActiveRecord::Base
  attr_accessible :ticket, :username
end
