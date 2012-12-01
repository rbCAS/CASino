module CASinoCore
  class Settings
    class << self
      def init(config = {})
        config.each do |key,value|
          puts "#{key} = #{value}"
          define_singleton_method key do
            value
          end
        end
      end

      def method_missing(method_id, *args)
        raise "#{method_id} is not defined in #{self.to_s}"
      end
    end
  end
end
