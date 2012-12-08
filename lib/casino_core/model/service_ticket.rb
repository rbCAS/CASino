require 'casino_core/model'
require 'casino_core/settings'

class CASinoCore::Model::ServiceTicket < ActiveRecord::Base
  autoload :SingleSignOutNotifier, 'casino_core/model/service_ticket/single_sign_out_notifier.rb'

  attr_accessible :ticket, :service
  validates :ticket, uniqueness: true
  belongs_to :ticket_granting_ticket
  before_destroy :send_single_sing_out_notification

  def self.cleanup_unconsumed
    self.delete_all(['created_at < ? AND consumed = ?', CASinoCore::Settings.service_ticket[:lifetime_unconsumed].seconds.ago, false])
  end

  def self.cleanup_consumed
    self.destroy_all(['created_at < ? AND consumed = ?', CASinoCore::Settings.service_ticket[:lifetime_consumed].seconds.ago, true]).length
  end

  def service_with_ticket_url
    service_uri = URI.parse(service)
    if service.include? '?'
      if service_uri.query.empty?
        query_separator = ''
      else
        query_separator = '&'
      end
    else
      query_separator = '?'
    end
    self.service + query_separator + 'ticket=' + self.ticket
  end

  private
  def send_single_sing_out_notification
    notifier = SingleSignOutNotifier.new(self)
    notifier.notify
  end
end
