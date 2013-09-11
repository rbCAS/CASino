# The ProxyTicketValidator processor should be used to handle GET requests to /proxyValidate
class CASino::ProxyTicketValidatorProcessor < CASino::ServiceTicketValidatorProcessor

  # This method will call `#validation_succeeded` or `#validation_failed`. In both cases, it supplies
  # a string as argument. The web application should present that string (and nothing else) to the
  # requestor. The Content-Type should be set to 'text/xml; charset=utf-8'
  #
  # @param [Hash] params parameters delivered by the client
  def process(params = nil)
    params ||= {}
    if request_valid?(params)
      ticket = if params[:ticket].start_with?('PT-')
        CASino::ProxyTicket.where(ticket: params[:ticket]).first
      elsif params[:ticket].start_with?('ST-')
        CASino::ServiceTicket.where(ticket: params[:ticket]).first
      else
        nil
      end
      validate_ticket!(ticket, params)
    end
  end
end
