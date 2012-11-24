def test_sign_in(options = {})
  request.env['HTTP_USER_AGENT'] = options[:user_agent] || 'TestBrowser 1.2'
  ticket = TicketGrantingTicket.create!({
    ticket: controller.random_ticket_string('TGC'),
    username: options[:username] || 'user1',
    extra_attributes: options[:extra_attributes],
    user_agent: request.env['HTTP_USER_AGENT']
  })
  request.cookies[:tgt] = ticket.ticket
end
