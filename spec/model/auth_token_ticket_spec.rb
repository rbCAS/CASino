require 'spec_helper'

describe CASino::AuthTokenTicket do
  describe '.cleanup' do
    it 'deletes expired auth token tickets' do
      ticket = described_class.new ticket: 'ATT-12345'
      ticket.save!
      ticket.created_at = 10.minutes.ago
      ticket.save!
      lambda do
        described_class.cleanup
      end.should change(described_class, :count).by(-1)
      described_class.find_by_ticket('ATT-12345').should be_falsey
    end
  end

  describe '#to_s' do
    it 'returns the ticket identifier' do
      ticket = described_class.new ticket: 'ATT-12345'
      "#{ticket}".should == ticket.ticket
    end
  end
end
