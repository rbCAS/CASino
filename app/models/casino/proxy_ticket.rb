require 'addressable/uri'

class CASino::ProxyTicket < ActiveRecord::Base
  include CASino::ModelConcern::Ticket

  self.ticket_prefix = 'PT'.freeze

  validates :ticket, uniqueness: true
  belongs_to :proxy_granting_ticket
  has_many :proxy_granting_tickets, as: :granter, dependent: :destroy

  def self.cleanup_unconsumed
    self.destroy_all(['created_at < ? AND consumed = ?', CASino.config.proxy_ticket[:lifetime_unconsumed].seconds.ago, false])
  end

  def self.cleanup_consumed
    self.destroy_all(['created_at < ? AND consumed = ?', CASino.config.proxy_ticket[:lifetime_consumed].seconds.ago, true])
  end

  def expired?
    lifetime = if consumed?
      CASino.config.proxy_ticket[:lifetime_consumed]
    else
      CASino.config.proxy_ticket[:lifetime_unconsumed]
    end
    (Time.now - (self.created_at || Time.now)) > lifetime
  end
end
