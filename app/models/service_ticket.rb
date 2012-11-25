class ServiceTicket < ActiveRecord::Base
  attr_accessible :ticket, :service
  validates :ticket, uniqueness: true
  belongs_to :ticket_granting_ticket

  def self.cleanup_unconsumed
    self.delete_all(['created_at < ? AND consumed = ?', Yetting.service_ticket['lifetime_unconsumed'].seconds.ago, false])
  end

  def self.cleanup_consumed
    self.delete_all(['created_at < ? AND consumed = ?', Yetting.service_ticket['lifetime_consumed'].seconds.ago, true])
  end
end
