class LoginTicket < ActiveRecord::Base
  attr_accessible :ticket
  validates :ticket, uniqueness: true

  def self.cleanup
    self.delete_all(['created_at < ?', Yetting.login_ticket['lifetime'].seconds.ago])
  end
end
