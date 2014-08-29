def sign_in(ticket_granting_ticket)
  request.cookies[:tgt] = ticket_granting_ticket.ticket
  request.user_agent = ticket_granting_ticket.user_agent
end
