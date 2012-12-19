require 'casino_core/settings'

module CASinoCore
  module Helper
    module Logger
      def logger
        CASinoCore::Settings.logger
      end
    end
  end
end
