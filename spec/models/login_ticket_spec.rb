require 'spec_helper'

describe CASinoCore::Model::LoginTicket do
  describe '.cleanup' do
    it 'should delete expired login tickets' do
      ticket = described_class.new ticket: 'LT-12345'
      ticket.save!
      ticket.created_at = 10.hours.ago
      ticket.save!
      lambda do
        described_class.cleanup
      end.should change(described_class, :count).by(-1)
      described_class.find_by_ticket('LT-12345').should be_false
    end
  end
end
