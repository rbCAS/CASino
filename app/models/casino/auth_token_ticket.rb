class CASino::AuthTokenTicket < ActiveRecord::Base
  include CASino::ModelConcern::Ticket
  include CASino::ModelConcern::ConsumableTicket

  self.ticket_prefix = 'ATT'.freeze

  def self.cleanup
    delete_all(['created_at < ?', CASino.config.auth_token_ticket[:lifetime].seconds.ago])
  end

  def expired?
    (Time.now - (self.created_at || Time.now)) > CASino.config.auth_token_ticket[:lifetime].seconds
  end

end
