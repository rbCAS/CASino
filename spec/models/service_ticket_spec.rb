require 'spec_helper'

describe ServiceTicket do
  let(:ticket) {
    ticket = ServiceTicket.new ticket: 'ST-12345', service: 'https://example.com/cas-service'
    ticket.ticket_granting_ticket_id = 1
    ticket
  }

  describe '.cleanup_unconsumed' do
    it 'should delete expired unconsumed service tickets' do
      ticket.created_at = 10.hours.ago
      ticket.save!
      lambda do
        ServiceTicket.cleanup_unconsumed
      end.should change(ServiceTicket, :count).by(-1)
      ServiceTicket.find_by_ticket('ST-12345').should be_false
    end
  end

  describe '.cleanup_consumed' do
    before(:each) do
      ServiceTicket::SingleSignOutNotifier.any_instance.stub(:notify).and_return(true)
    end

    it 'should delete expired consumed service tickets' do
      ticket.consumed = true
      ticket.created_at = 10.days.ago
      ticket.save!
      lambda do
        ServiceTicket.cleanup_consumed
      end.should change(ServiceTicket, :count).by(-1)
      ServiceTicket.find_by_ticket('ST-12345').should be_false
    end
  end

  describe '.destroy' do
    it 'should send out a single sign out notification' do
      ServiceTicket::SingleSignOutNotifier.any_instance.should_receive(:notify).and_return(true)
      ticket.consumed = true
      ticket.save!
      ticket.destroy
    end
  end
end
