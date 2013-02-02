require 'spec_helper'
require 'useragent'

describe CASinoCore::Model::TicketGrantingTicket do
  let(:ticket_granting_ticket) { FactoryGirl.create :ticket_granting_ticket }
  let(:service_ticket) { FactoryGirl.create :service_ticket, ticket_granting_ticket: ticket_granting_ticket }
  let(:consumed_service_ticket) { FactoryGirl.create :service_ticket, :consumed, ticket_granting_ticket: ticket_granting_ticket }

  describe '#destroy' do
    context 'when notification for a service ticket fails' do
      before(:each) do
        CASinoCore::Model::ServiceTicket::SingleSignOutNotifier.any_instance.stub(:notify).and_return(false)
      end

      it 'deletes depending proxy-granting tickets' do
        consumed_service_ticket.proxy_granting_tickets.create! ticket: 'PGT-12345', iou: 'PGTIOU-12345', pgt_url: 'bla'
        lambda {
          ticket_granting_ticket.destroy
        }.should change(CASinoCore::Model::ProxyGrantingTicket, :count).by(-1)
      end

      it 'nullifies depending service tickets' do
        lambda {
          ticket_granting_ticket.destroy
        }.should change { consumed_service_ticket.reload.ticket_granting_ticket_id }.from(ticket_granting_ticket.id).to(nil)
      end
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
end
