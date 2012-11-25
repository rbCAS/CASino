module SessionsHelper
  def acquire_login_ticket
    ticket = LoginTicket.create ticket: random_ticket_string('LT')
    logger.debug "Created login ticket '#{ticket.ticket}'"
    ticket
  end

  def current_ticket_granting_ticket
    if !@current_ticket_granting_ticket.nil?
      @current_ticket_granting_ticket
    elsif cookies.has_key?(:tgt)
      ticket_granting_ticket = TicketGrantingTicket.where(ticket: cookies[:tgt]).first
      unless ticket_granting_ticket.nil?
        if same_browser?(ticket_granting_ticket.user_agent, request.env['HTTP_USER_AGENT'])
          ticket_granting_ticket.user_agent = request.env['HTTP_USER_AGENT']
          ticket_granting_ticket.save!
          @current_ticket_granting_ticket = ticket_granting_ticket
          return ticket_granting_ticket
        else
          logger.info 'User-Agent changed: ticket-granting ticket not valid for this browser'
        end
      end
      cookies.delete(:tgt)
      nil
    else
      nil
    end
  end

  def current_ticket_granting_ticket?(ticket_granting_ticket)
    current_ticket_granting_ticket == ticket_granting_ticket
  end

  def signed_in?
    !current_ticket_granting_ticket.nil?
  end

  def authenticate
    deny_access unless signed_in?
  end

  def deny_access
    flash.now[:error] = 'Please sign in to access this page.'
    render 'new', status: 403
  end
end
