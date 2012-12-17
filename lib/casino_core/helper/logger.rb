module CASinoCore
  module Helper
    module Logger
      def logger
        # TODO this is just a "silent logger", make logger a setting!
        logger = ::Logger.new(STDOUT)
        logger.level = ::Logger::Severity::UNKNOWN
        logger
      end
    end
  end
end
