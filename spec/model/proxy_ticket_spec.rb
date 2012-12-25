require 'spec_helper'

describe CASinoCore::Model::ProxyTicket do
  let(:ticket) {
    ticket = described_class.new ticket: 'PT-12345', service: 'any string is valid'
    ticket.proxy_granting_ticket_id = 1
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
    it 'deletes expired consumed service tickets' do
      ticket.consumed = true
      ticket.created_at = 10.days.ago
      ticket.save!
      lambda do
        described_class.cleanup_consumed
      end.should change(described_class, :count).by(-1)
      described_class.find_by_ticket('ST-12345').should be_false
    end
  end
end
