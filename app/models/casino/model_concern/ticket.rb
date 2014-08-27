module CASino::ModelConcern::Ticket
  extend ActiveSupport::Concern

  included do
    validates :ticket, uniqueness: true
    before_create :ensure_ticket_present
    class_attribute :ticket_prefix, :ticket_lifetime
  end

  module ClassMethods
    def cleanup
      delete_all(['created_at < ?', ticket_lifetime.ago])
    end
  end

  def to_s
    ticket
  end

  private
  TICKET_ALLOWED_CHARACTERS = ('A'..'Z').to_a + ('a'..'z').to_a + ('0'..'9').to_a
  TICKET_LENGTH = 40

  def ensure_ticket_present
    self.ticket ||= create_random_ticket_string
  end

  def create_random_ticket_string
    random_string = SecureRandom.random_bytes(TICKET_LENGTH).each_char.map do |char|
      TICKET_ALLOWED_CHARACTERS[(char.ord % TICKET_ALLOWED_CHARACTERS.length)]
    end.join
    "#{self.class.ticket_prefix}-#{'%d' % (Time.now.to_f * 10000)}-#{random_string}"
  end
end
