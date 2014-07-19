require 'spec_helper'

describe CASino::ProxyTicket do
  let(:unconsumed_ticket) {
    ticket = described_class.new ticket: 'PT-12345', service: 'any_string_is_valid'
    ticket.proxy_granting_ticket_id = 1
    ticket
  }
  let(:consumed_ticket) {
    ticket = described_class.new ticket: 'PT-54321', service: 'any_string_is_valid'
    ticket.proxy_granting_ticket_id = 1
    ticket.consumed = true
    ticket.save!
    ticket
  }

  describe '#expired?' do
    [:unconsumed, :consumed].each do |state|
      context "with an #{state} ticket" do
        let(:ticket) { send("#{state}_ticket") }

        context 'with an expired ticket' do
          before(:each) do
            ticket.created_at = (CASino.config.service_ticket[:"lifetime_#{state}"].seconds + 1).ago
            ticket.save!
          end

          it 'returns true' do
            ticket.expired?.should == true
          end
        end

        context 'with an unexpired ticket' do
          it 'returns false' do
            ticket.expired?.should == false
          end
        end
      end
    end
  end

  describe '.cleanup_unconsumed' do
    it 'deletes expired unconsumed service tickets' do
      unconsumed_ticket.created_at = 10.hours.ago
      unconsumed_ticket.save!
      lambda do
        described_class.cleanup_unconsumed
      end.should change(described_class, :count).by(-1)
      described_class.find_by_ticket('PT-12345').should be_falsey
    end
  end

  describe '.cleanup_consumed' do
    it 'deletes expired consumed service tickets' do
      consumed_ticket.created_at = 10.days.ago
      consumed_ticket.save!
      lambda do
        described_class.cleanup_consumed
      end.should change(described_class, :count).by(-1)
      described_class.find_by_ticket('PT-12345').should be_falsey
    end
  end
end
