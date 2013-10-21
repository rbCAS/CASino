# This processor should be used for GET requests to /login
class CASino::LoginCredentialRequestorProcessor < CASino::Processor
  include CASino::ProcessorConcern::Browser
  include CASino::ProcessorConcern::LoginTickets
  include CASino::ProcessorConcern::ServiceTickets
  include CASino::ProcessorConcern::TicketGrantingTickets

  # Use this method to process the request.
  #
  # The method will call one of the following methods on the listener:
  # * `#user_logged_in`: The first argument (String) is the URL (if any), the user should be redirected to.
  # * `#user_not_logged_in`: The first argument is a LoginTicket. It should be stored in a hidden field with name "lt".
  # * `#service_not_allowed`: The user tried to access a service that this CAS server is not allowed to serve.
  #
  # @param [Hash] params parameters supplied by user
  # @param [Hash] cookies cookies supplied by user
  # @param [String] user_agent user-agent delivered by the client
  def process(params = nil, cookies = nil, user_agent = nil)
    @params = params || {}
    @cookies = cookies || {}
    @user_agent = user_agent || {}
    if check_service_allowed
      handle_allowed_service
    end
  end

  private
  def handle_allowed_service
    if !@params[:renew] && (@ticket_granting_ticket = find_valid_ticket_granting_ticket(@cookies[:tgt], @user_agent))
      handle_logged_in
    else
      handle_not_logged_in
    end
  end

  def handle_logged_in
    service_url_with_ticket = unless @params[:service].nil?
      acquire_service_ticket(@ticket_granting_ticket, @params[:service], true).service_with_ticket_url
    end
    @listener.user_logged_in(service_url_with_ticket)
  end

  def handle_not_logged_in
    if gateway_request?
      # we actually lie to the listener to simplify things
      @listener.user_logged_in(@params[:service])
    else
      login_ticket = acquire_login_ticket
      @listener.user_not_logged_in(login_ticket)
    end
  end

  def check_service_allowed
    service_url = clean_service_url(@params[:service]) unless @params[:service].nil?
    if service_url.nil? || CASino::ServiceRule.allowed?(service_url)
      true
    else
      @listener.service_not_allowed(service_url)
      false
    end
  end

  def gateway_request?
    @params[:gateway] == 'true' && @params[:service]
  end
end
