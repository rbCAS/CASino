require 'addressable/uri'

module CASino::ServiceTicketProcessor
  extend ActiveSupport::Concern

  class ServiceNotAllowedError < StandardError; end
  class ValidationResult < CASino::ValidationResult; end

  RESERVED_CAS_PARAMETER_KEYS = ['service', 'ticket', 'gateway', 'renew']

  def service_allowed?(service)
    CASino::ServiceRule.allowed?(service)
  end

  def acquire_service_ticket(ticket_granting_ticket, service, options = {})
    service_url = clean_service_url(service)
    unless service_allowed?(service_url)
      message = "#{service_url} is not in the list of allowed URLs"
      Rails.logger.error message
      raise ServiceNotAllowedError, message
    end
    service_tickets = ticket_granting_ticket.service_tickets
    service_tickets.where(service: service_url).destroy_all
    service_tickets.create!({
      service: service_url,
      issued_from_credentials: !!options[:credentials_supplied]
    })
  end

  def clean_service_url(dirty_service)
    return dirty_service if dirty_service.blank?
    service_uri = Addressable::URI.parse dirty_service
    unless service_uri.query_values.nil?
      service_uri.query_values = service_uri.query_values(Array).select { |k,v| !RESERVED_CAS_PARAMETER_KEYS.include?(k) }
    end
    if service_uri.query_values.blank?
      service_uri.query_values = nil
    end

    service_uri.path = (service_uri.path || '').gsub(/\/+\z/, '')
    service_uri.path = '/' if service_uri.path.blank?

    service_uri.normalize.to_s.tap do |clean_service|
      Rails.logger.debug("Cleaned dirty service URL '#{dirty_service}' to '#{clean_service}'") if dirty_service != clean_service
    end
  end

  def ticket_valid_for_service?(ticket, service, options = {})
    validate_ticket_for_service(ticket, service, options).success?
  end

  def validate_ticket_for_service(ticket, service, options = {})
    if ticket.nil?
      result = ValidationResult.new 'INVALID_TICKET', 'Invalid validate request: Ticket does not exist', :warn
    else
      result = validate_existing_ticket_for_service(ticket, service, options)
      ticket.update_attribute(:consumed, true)
      Rails.logger.debug "Consumed ticket '#{ticket.ticket}'"
    end
    if result.success?
      Rails.logger.info "Ticket '#{ticket.ticket}' for service '#{service}' successfully validated"
    else
      Rails.logger.send(result.error_severity, result.error_message)
    end
    result
  end

  private
  def validate_existing_ticket_for_service(ticket, service, options = {})
    service = clean_service_url(service) if ticket.is_a?(CASino::ServiceTicket)
    if ticket.consumed?
      ValidationResult.new 'INVALID_TICKET', "Ticket '#{ticket.ticket}' already consumed", :warn
    elsif ticket.expired?
      ValidationResult.new 'INVALID_TICKET', "Ticket '#{ticket.ticket}' has expired", :warn
    elsif service != ticket.service
      ValidationResult.new 'INVALID_SERVICE', "Ticket '#{ticket.ticket}' is not valid for service '#{service}'", :warn
    elsif options[:renew] && !ticket.issued_from_credentials?
      ValidationResult.new 'INVALID_TICKET', "Ticket '#{ticket.ticket}' was not issued from credentials but service '#{service}' will only accept a renewed ticket", :info
    else
      ValidationResult.new
    end
  end
end
