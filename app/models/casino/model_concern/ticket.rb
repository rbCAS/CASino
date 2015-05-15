module CASino::ModelConcern::Ticket
  extend ActiveSupport::Concern

  included do
    before_validation :ensure_ticket_present
    validates :ticket, uniqueness: true
    class_attribute :ticket_prefix
  end

  def to_s
    ticket
  end

  private
  TICKET_ALLOWED_CHARACTERS = ('A'..'Z').to_a + ('a'..'z').to_a + ('0'..'9').to_a
  TICKET_LENGTH = 40

  def ensure_ticket_present
    self.ticket ||= create_random_ticket_string(self.class.ticket_prefix)
  end

  def create_random_ticket_string(prefix)
    random_string = SecureRandom.random_bytes(TICKET_LENGTH).each_char.map do |char|
      TICKET_ALLOWED_CHARACTERS[(char.ord % TICKET_ALLOWED_CHARACTERS.length)]
    end.join
    "#{prefix}-#{'%d' % (Time.now.to_f * 10000)}-#{random_string}"
  end
end
