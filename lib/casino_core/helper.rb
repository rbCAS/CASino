require 'logger'
require 'useragent'

module CASinoCore
  module Helper
    autoload :Browser, 'casino_core/helper/browser.rb'
    autoload :Logger, 'casino_core/helper/logger.rb'
    autoload :LoginTickets, 'casino_core/helper/login_tickets.rb'
    autoload :ServiceTickets, 'casino_core/helper/service_tickets.rb'
    autoload :Tickets, 'casino_core/helper/tickets.rb'
  end
end
