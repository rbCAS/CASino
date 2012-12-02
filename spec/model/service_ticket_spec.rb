require 'spec_helper'

describe CASinoCore::Model::ServiceTicket do
  let(:ticket) {
    ticket = described_class.new ticket: 'ST-12345', service: 'https://example.com/cas-service'
    ticket.ticket_granting_ticket_id = 1
    ticket
  }

  describe '.cleanup_unconsumed' do
    it 'should delete expired unconsumed service tickets' do
      ticket.created_at = 10.hours.ago
      ticket.save!
      lambda do
        described_class.cleanup_unconsumed
      end.should change(described_class, :count).by(-1)
      described_class.find_by_ticket('ST-12345').should be_false
    end
  end

  describe '.cleanup_consumed' do
    before(:each) do
      described_class::SingleSignOutNotifier.any_instance.stub(:notify).and_return(true)
    end

    it 'should delete expired consumed service tickets' do
      ticket.consumed = true
      ticket.created_at = 10.days.ago
      ticket.save!
      lambda do
        described_class.cleanup_consumed
      end.should change(described_class, :count).by(-1)
      described_class.find_by_ticket('ST-12345').should be_false
    end
  end

  describe '.destroy' do
    it 'should send out a single sign out notification' do
      described_class::SingleSignOutNotifier.any_instance.should_receive(:notify).and_return(true)
      ticket.consumed = true
      ticket.save!
      ticket.destroy
    end
  end
end
