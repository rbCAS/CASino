require 'securerandom'

module CASinoCore
  module Helper
    module Tickets

      ALLOWED_TICKET_STRING_CHARACTERS = ('A'..'Z').to_a + ('a'..'z').to_a + ('0'..'9').to_a

      def random_ticket_string(prefix, length = 40)
        random_string = SecureRandom.random_bytes(length).each_char.map do |char|
          ALLOWED_TICKET_STRING_CHARACTERS[(char.ord % ALLOWED_TICKET_STRING_CHARACTERS.length)]
        end.join
        "#{prefix}-#{Time.now.to_i}-#{random_string}"
      end
    end
  end
end
