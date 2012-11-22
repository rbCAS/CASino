class TicketGrantingTicket < ActiveRecord::Base
  attr_accessible :ticket, :username, :user_agent, :extra_attributes
  serialize :extra_attributes, Hash
  validates :ticket, uniqueness: true
end
