module CASino::ModelConcern::ConsumableTicket
  extend ActiveSupport::Concern

  module ClassMethods
    def consume(ticket_identifier)
      ticket = find_by_ticket(ticket_identifier)
      if ticket.nil?
        Rails.logger.info "#{model_name.human} '#{ticket_identifier}' not found"
        false
      elsif ticket.expired?
        Rails.logger.info "#{model_name.human} '#{ticket.ticket}' expired"
        false
      else
        Rails.logger.debug "#{model_name.human} '#{ticket.ticket}' successfully validated"
        ticket.delete
        true
      end
    end
  end
end
