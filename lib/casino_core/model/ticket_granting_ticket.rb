require 'casino_core/model'

class CASinoCore::Model::TicketGrantingTicket < ActiveRecord::Base
  attr_accessible :ticket, :user_agent, :awaiting_two_factor_authentication
  validates :ticket, uniqueness: true

  belongs_to :user
  has_many :service_tickets, dependent: :destroy

  def self.cleanup
    self.destroy_all(['created_at < ?', CASinoCore::Settings.ticket_granting_ticket[:lifetime].seconds.ago])
  end

  def browser_info
    unless self.user_agent.blank?
      user_agent = UserAgent.parse(self.user_agent)
      if user_agent.platform.nil?
        "#{user_agent.browser}"
      else
        "#{user_agent.browser} (#{user_agent.platform})"
      end
    end
  end

  def same_user?(other_ticket)
    if other_ticket.nil?
      false
    else
      other_ticket.user_id == self.user_id
    end
  end

  def expired?
    lifetime = CASinoCore::Settings.ticket_granting_ticket[:lifetime]
    (Time.now - (self.created_at || Time.now)) > lifetime
  end
end
