class CASino::LoginTicket < ActiveRecord::Base
  include CASino::ModelConcern::Ticket
  include CASino::ModelConcern::ConsumableTicket

  self.ticket_prefix = 'LT'.freeze
  self.ticket_lifetime = CASino.config.login_ticket[:lifetime].seconds
end
