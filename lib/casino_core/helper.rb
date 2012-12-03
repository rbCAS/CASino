require 'logger'

module CASinoCore
  module Helper
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
