require 'casino_core/model'

class CASinoCore::Model::TicketGrantingTicket < ActiveRecord::Base
  attr_accessible :ticket, :user_agent, :awaiting_two_factor_authentication, :long_term
  validates :ticket, uniqueness: true

  belongs_to :user
  has_many :service_tickets, dependent: :destroy

  def self.cleanup(user = nil)
    if user.nil?
      base = self
    else
      base = user.ticket_granting_tickets
    end
    base.where([
      '(created_at < ? AND awaiting_two_factor_authentication = ?) OR (created_at < ? AND long_term = ?) OR created_at < ?',
      CASinoCore::Settings.two_factor_authenticator[:timeout].seconds.ago,
      true,
      CASinoCore::Settings.ticket_granting_ticket[:lifetime].seconds.ago,
      false,
      CASinoCore::Settings.ticket_granting_ticket[:lifetime_long_term].seconds.ago
    ]).destroy_all
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
    if awaiting_two_factor_authentication?
      lifetime = CASinoCore::Settings.two_factor_authenticator[:timeout]
    elsif long_term?
      lifetime = CASinoCore::Settings.ticket_granting_ticket[:lifetime_long_term]
    else
      lifetime = CASinoCore::Settings.ticket_granting_ticket[:lifetime]
    end
    (Time.now - (self.created_at || Time.now)) > lifetime
  end
end
