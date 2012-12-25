require 'casino_core/model'
require 'casino_core/settings'
require 'addressable/uri'

class CASinoCore::Model::ServiceTicket < ActiveRecord::Base
  autoload :SingleSignOutNotifier, 'casino_core/model/service_ticket/single_sign_out_notifier.rb'

  attr_accessible :ticket, :service
  validates :ticket, uniqueness: true
  belongs_to :ticket_granting_ticket
  before_destroy :send_single_sing_out_notification, if: :consumed?
  has_many :proxy_granting_tickets

  def self.cleanup_unconsumed
    self.destroy_all(['created_at < ? AND consumed = ?', CASinoCore::Settings.service_ticket[:lifetime_unconsumed].seconds.ago, false])
  end

  def self.cleanup_consumed
    self.destroy_all(['created_at < ? AND consumed = ?', CASinoCore::Settings.service_ticket[:lifetime_consumed].seconds.ago, true])
  end

  def service_with_ticket_url
    service_uri = Addressable::URI.parse(self.service)
    service_uri.query_values = (service_uri.query_values || {}).merge(ticket: self.ticket)
    service_uri.to_s
  end

  private
  def send_single_sing_out_notification
    notifier = SingleSignOutNotifier.new(self)
    notifier.notify
  end
end
