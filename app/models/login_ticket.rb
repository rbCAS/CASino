class LoginTicket < ActiveRecord::Base
  attr_accessible :ticket
  validates :ticket, uniqueness: true
end
