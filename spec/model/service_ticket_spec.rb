require 'spec_helper'

describe CASinoCore::Model::ServiceTicket do
  let(:ticket) {
    ticket = described_class.new ticket: 'ST-12345', service: 'https://example.com/cas-service'
    ticket.ticket_granting_ticket_id = 1
    ticket
  }
  let(:consumed_ticket) {
    ticket = described_class.new ticket: 'ST-54321', service: 'https://example.com/cas-service'
    ticket.ticket_granting_ticket_id = 1
    ticket.consumed = true
    ticket.save!
    ticket
  }

  describe '.cleanup_unconsumed' do
    it 'deletes expired unconsumed service tickets' do
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

    it 'deletes expired consumed service tickets' do
      consumed_ticket.created_at = 10.days.ago
      consumed_ticket.save!
      lambda do
        described_class.cleanup_consumed
      end.should change(described_class, :count).by(-1)
      described_class.find_by_ticket('ST-12345').should be_false
    end

    it 'deletes consumed service tickets without ticket_granting_ticket' do
      consumed_ticket.ticket_granting_ticket_id = nil
      consumed_ticket.save!
      lambda do
        described_class.cleanup_consumed
      end.should change(described_class, :count).by(-1)
      described_class.find_by_ticket('ST-12345').should be_false
    end

    it 'does not delete unexpired service tickets' do
      consumed_ticket # create the ticket
      lambda do
        described_class.cleanup_consumed
      end.should_not change(described_class, :count)
    end
  end

  describe '#destroy' do
    it 'sends out a single sign out notification' do
      described_class::SingleSignOutNotifier.any_instance.should_receive(:notify).and_return(true)
      consumed_ticket.destroy
    end

    context 'when notification fails' do
      before(:each) do
        described_class::SingleSignOutNotifier.any_instance.stub(:notify).and_return(false)
      end

      it 'does not delete the service ticket' do
        consumed_ticket
        lambda {
          consumed_ticket.destroy
        }.should_not change(CASinoCore::Model::ServiceTicket, :count)
      end
    end
  end
end
