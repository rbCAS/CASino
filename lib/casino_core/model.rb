require 'active_record'

module CASinoCore
  module Model
    autoload :LoginTicket, 'casino_core/model/login_ticket.rb'
    autoload :ServiceRule, 'casino_core/model/service_rule.rb'
    autoload :ServiceTicket, 'casino_core/model/service_ticket.rb'
    autoload :ProxyGrantingTicket, 'casino_core/model/proxy_granting_ticket.rb'
    autoload :ProxyTicket, 'casino_core/model/proxy_ticket.rb'
    autoload :TicketGrantingTicket, 'casino_core/model/ticket_granting_ticket.rb'
  end
end
