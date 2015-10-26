require 'spec_helper'
require 'useragent'

describe CASino::TicketGrantingTicket do
  let(:ticket_granting_ticket) { FactoryGirl.create :ticket_granting_ticket }
  let(:service_ticket) { FactoryGirl.create :service_ticket, ticket_granting_ticket: ticket_granting_ticket }

  describe '#destroy' do
    let!(:consumed_service_ticket) { FactoryGirl.create :service_ticket, :consumed, ticket_granting_ticket: ticket_granting_ticket }

    context 'when notification for a service ticket fails' do
      before(:each) do
        CASino::ServiceTicket::SingleSignOutNotifier.any_instance.stub(:notify).and_return(false)
      end

      it 'deletes depending proxy-granting tickets' do
        consumed_service_ticket.proxy_granting_tickets.create! ticket: 'PGT-12345', iou: 'PGTIOU-12345', pgt_url: 'bla'
        lambda {
          ticket_granting_ticket.destroy
        }.should change(CASino::ProxyGrantingTicket, :count).by(-1)
      end

      it 'deletes depending service tickets' do
        lambda {
          ticket_granting_ticket.destroy
        }.should change(CASino::ServiceTicket, :count).by(-1)
      end
    end
  end

  describe "user_ip" do

    it 'returns request remote_ip' do
      ticket_granting_ticket.user_ip.should == '127.0.0.1'
    end
    
  end

  describe '#browser_info' do
    let(:user_agent) { Object.new }
    before(:each) do
      user_agent.stub(:browser).and_return('TestBrowser')
      UserAgent.stub(:parse).and_return(user_agent)
    end

    context 'without platform' do
      before(:each) do
        user_agent.stub(:platform).and_return(nil)
      end

      it 'returns the browser name' do
        ticket_granting_ticket.browser_info.should == 'TestBrowser'
      end
    end

    context 'with a platform' do
      before(:each) do
        user_agent.stub(:platform).and_return('Linux')
      end

      it 'returns the browser name' do
        ticket_granting_ticket.browser_info.should == 'TestBrowser (Linux)'
      end
    end
  end

  describe '#same_user?' do
    context 'with a nil value' do
      let(:other_ticket_granting_ticket) { nil }

      it 'should return false' do
        ticket_granting_ticket.same_user?(other_ticket_granting_ticket).should == false
      end
    end

    context 'with a ticket from another user' do
      let(:other_ticket_granting_ticket) { FactoryGirl.create :ticket_granting_ticket  }

      it 'should return false' do
        ticket_granting_ticket.same_user?(other_ticket_granting_ticket).should == false
      end
    end

    context 'with a ticket from the same user' do
      let(:other_ticket_granting_ticket) { FactoryGirl.create :ticket_granting_ticket, user: ticket_granting_ticket.user }

      it 'should return true' do
        ticket_granting_ticket.same_user?(other_ticket_granting_ticket).should == true
      end
    end
  end

  describe '#expired?' do
    context 'with a long-term ticket' do
      context 'when almost expired' do
        before(:each) do
          ticket_granting_ticket.created_at = 9.days.ago
          ticket_granting_ticket.long_term = true
          ticket_granting_ticket.save!
        end

        it 'returns false' do
          ticket_granting_ticket.expired?.should == false
        end
      end

      context 'when expired' do
        before(:each) do
          ticket_granting_ticket.created_at = 30.days.ago
          ticket_granting_ticket.long_term = true
          ticket_granting_ticket.save!
        end

        it 'returns true' do
          ticket_granting_ticket.expired?.should == true
        end
      end
    end

    context 'with an expired ticket' do
      before(:each) do
        ticket_granting_ticket.created_at = 25.hours.ago
        ticket_granting_ticket.save!
      end

      it 'returns true' do
        ticket_granting_ticket.expired?.should == true
      end
    end

    context 'with an unexpired ticket' do
      it 'returns false' do
        ticket_granting_ticket.expired?.should == false
      end
    end

    context 'with pending two-factor authentication' do
      before(:each) do
        ticket_granting_ticket.awaiting_two_factor_authentication = true
        ticket_granting_ticket.save!
      end

      context 'with an expired ticket' do
        before(:each) do
          ticket_granting_ticket.created_at = 10.minutes.ago
          ticket_granting_ticket.save!
        end

        it 'returns true' do
          ticket_granting_ticket.expired?.should == true
        end
      end

      context 'with an unexpired ticket' do
        it 'returns false' do
          ticket_granting_ticket.expired?.should == false
        end
      end
    end
  end

  describe '.cleanup' do
    let!(:other_ticket_granting_ticket) { FactoryGirl.create :ticket_granting_ticket }

    it 'deletes expired ticket-granting tickets' do
      ticket_granting_ticket.created_at = 25.hours.ago
      ticket_granting_ticket.save!
      lambda do
        described_class.cleanup
      end.should change(described_class, :count).by(-1)
      described_class.find_by_ticket(ticket_granting_ticket.ticket).should be_falsey
    end

    it 'does not delete almost expired long-term ticket-granting tickets' do
      ticket_granting_ticket.created_at = 9.days.ago
      ticket_granting_ticket.long_term = true
      ticket_granting_ticket.save!
      lambda do
        described_class.cleanup
      end.should_not change(described_class, :count)
    end

    it 'does delete expired long-term ticket-granting tickets' do
      ticket_granting_ticket.created_at = 30.days.ago
      ticket_granting_ticket.long_term = true
      ticket_granting_ticket.save!
      lambda do
        described_class.cleanup
      end.should change(described_class, :count).by(-1)
      described_class.find_by_ticket(ticket_granting_ticket.ticket).should be_falsey
    end

    it 'does not delete almost expired ticket-granting tickets with pending two-factor authentication' do
      ticket_granting_ticket.created_at = 2.minutes.ago
      ticket_granting_ticket.awaiting_two_factor_authentication = true
      ticket_granting_ticket.save!
      lambda do
        described_class.cleanup
      end.should_not change(described_class, :count)
    end

    it 'does delete expired ticket-granting tickets with pending two-factor authentication' do
      ticket_granting_ticket.created_at = 20.minutes.ago
      ticket_granting_ticket.awaiting_two_factor_authentication = true
      ticket_granting_ticket.save!
      lambda do
        described_class.cleanup
      end.should change(described_class, :count).by(-1)
      described_class.find_by_ticket(ticket_granting_ticket.ticket).should be_falsey
    end
  end
end
