require 'spec_helper'

describe ServiceTicket do
  describe '.cleanup' do
    it 'should delete expired service tickets' do
      ticket = ServiceTicket.new ticket: 'ST-12345', service: 'foo'
      ticket.ticket_granting_ticket_id = 1
      ticket.save!
      ticket.created_at = 10.hours.ago
      ticket.save!
      lambda do
        ServiceTicket.cleanup
      end.should change(ServiceTicket, :count).by(-1)
      ServiceTicket.find_by_ticket('ST-12345').should be_false
    end
  end
end
