require 'spec_helper'

describe CASino::ServiceTicket do
  let(:unconsumed_ticket) {
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
      described_class.find_by_ticket('ST-12345').should be_false
    end
  end

  describe '.cleanup_consumed_hard' do
    before(:each) do
      described_class::SingleSignOutNotifier.any_instance.stub(:notify).and_return(false)
    end

    it 'deletes consumed service tickets with an unreachable Single Sign Out callback server' do
      consumed_ticket.created_at = 10.days.ago
      consumed_ticket.save!
      lambda do
        described_class.cleanup_consumed_hard
      end.should change(described_class, :count).by(-1)
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

      it 'does delete the service ticket anyway' do
        consumed_ticket
        lambda {
          consumed_ticket.destroy
        }.should change(CASino::ServiceTicket, :count).by(-1)
      end
    end
  end

  describe '#service_with_ticket_url' do
    it 'does not escape the url from the database' do
      unconsumed_ticket.service = 'https://host.example.org/test.php?t=other&other=testing'
      unconsumed_ticket.service_with_ticket_url.should eq('https://host.example.org/test.php?t=other&other=testing&ticket=ST-12345')
    end
  end
end
