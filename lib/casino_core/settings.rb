module CASinoCore
  class Settings
    class << self
      attr_accessor :login_ticket, :service_ticket, :authenticators
      def init(config = {})
        config.each do |key,value|
          if respond_to?("#{key}=")
            send("#{key}=", value)
          end
        end
      end
    end
  end
end
