require 'logger'
require 'useragent'

module CASinoCore
  module Helper
    autoload :Browser, 'casino_core/helper/browser.rb'
    autoload :LoginTickets, 'casino_core/helper/login_tickets.rb'
    autoload :ServiceTickets, 'casino_core/helper/service_tickets.rb'

    def random_ticket_string(prefix, length = 40)
      random_string = rand(36**length).to_s(36)
      "#{prefix}-#{Time.now.to_i}-#{random_string}"
    end

    def logger
      # TODO this is just a "silent logger", make logger a setting!
      logger = ::Logger.new(STDOUT)
      logger.level = ::Logger::Severity::UNKNOWN
      logger
    end
  end
end
