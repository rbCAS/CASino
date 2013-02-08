require 'casino_core/model'

class CASinoCore::Model::TicketGrantingTicket < ActiveRecord::Base
  attr_accessible :ticket, :user_agent, :awaiting_two_factor_authentication
  validates :ticket, uniqueness: true

  belongs_to :user
  has_many :service_tickets

  before_destroy :destroy_service_tickets
  after_destroy :destroy_proxy_granting_tickets

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

  private
  def destroy_service_tickets
    self.service_tickets.each do |service_ticket|
      unless service_ticket.destroy
        service_ticket.ticket_granting_ticket_id = nil
        service_ticket.save
      end
    end
  end

  # Deletes proxy-granting tickets of service tickets that
  # could not be deleted (see #destroy_service_tickets)
  def destroy_proxy_granting_tickets
    self.service_tickets.each do |service_ticket|
      service_ticket.proxy_granting_tickets.destroy_all
    end
  end
end
