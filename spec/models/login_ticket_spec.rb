require 'spec_helper'

describe LoginTicket do
  it 'should delete old tickets' do
    ticket = LoginTicket.new ticket: 'LT-12345'
    ticket.save!
    ticket.created_at = 10.hours.ago
    ticket.save!
    lambda do
      LoginTicket.cleanup
    end.should change(LoginTicket, :count).by(-1)
    LoginTicket.find_by_ticket('LT-12345').should be_false
  end
end
