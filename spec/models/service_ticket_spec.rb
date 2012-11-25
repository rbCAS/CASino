require 'spec_helper'

describe ServiceTicket do
  describe '.cleanup_unconsumed' do
    it 'should delete expired unconsumed service tickets' do
      ticket = ServiceTicket.new ticket: 'ST-12345', service: 'foo'
      ticket.ticket_granting_ticket_id = 1
      ticket.created_at = 10.hours.ago
      ticket.save!
      lambda do
        ServiceTicket.cleanup_unconsumed
      end.should change(ServiceTicket, :count).by(-1)
      ServiceTicket.find_by_ticket('ST-12345').should be_false
    end
  end

  describe '.cleanup_consumed' do
    it 'should delete expired consumed service tickets' do
      ticket = ServiceTicket.new ticket: 'ST-12345', service: 'foo'
      ticket.ticket_granting_ticket_id = 1
      ticket.consumed = true
      ticket.created_at = 10.days.ago
      ticket.save!
      lambda do
        ServiceTicket.cleanup_consumed
      end.should change(ServiceTicket, :count).by(-1)
      ServiceTicket.find_by_ticket('ST-12345').should be_false
    end
  end
end
