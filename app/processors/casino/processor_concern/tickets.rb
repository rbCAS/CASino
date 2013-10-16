require 'securerandom'

module CASino
  module ProcessorConcern
    module Tickets

      ALLOWED_TICKET_STRING_CHARACTERS = ('A'..'Z').to_a + ('a'..'z').to_a + ('0'..'9').to_a

      def random_ticket_string(prefix, length = 40)
        random_string = SecureRandom.random_bytes(length).each_char.map do |char|
          ALLOWED_TICKET_STRING_CHARACTERS[(char.ord % ALLOWED_TICKET_STRING_CHARACTERS.length)]
        end.join
        "#{prefix}-#{'%d' % (Time.now.to_f * 10000)}-#{random_string}"
      end
    end
  end
end
