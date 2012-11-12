class LoginTicket < ActiveRecord::Base
  attr_accessible :ticket
  validates :ticket, uniqueness: true

  def self.cleanup
    self.delete_all(['created_at < ?', 2.hours.ago])
  end
end
