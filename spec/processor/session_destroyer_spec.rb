require 'spec_helper'

describe CASinoCore::Processor::SessionDestroyer do
  describe '#process' do
    let(:listener) { Object.new }
    let(:processor) { described_class.new(listener) }
    let(:owner_ticket_granting_ticket) { FactoryGirl.create :ticket_granting_ticket }
    let(:user_agent) { owner_ticket_granting_ticket.user_agent }
    let(:cookies) { { tgt: owner_ticket_granting_ticket.ticket } }

    before(:each) do
      listener.stub(:ticket_deleted)
      listener.stub(:ticket_not_found)
    end

    context 'with an existing ticket-granting ticket' do
      let(:ticket_granting_ticket) { FactoryGirl.create :ticket_granting_ticket }
      let(:service_ticket) {
        ticket_granting_ticket.service_tickets.create! ticket: 'ST-6NBRr5DAg2NW181H5chaHh', service: 'http://www.example.com'
      }
      let(:consumed_service_ticket) {
        st = ticket_granting_ticket.service_tickets.create! ticket: 'ST-6NBRr5DAg2NW181H5chaHh', service: 'http://www.example.com'
        st.consumed = true
        st.save!
        st
      }
      let(:params) { { id: ticket_granting_ticket.id } }

      it 'deletes only one ticket-granting ticket' do
        ticket_granting_ticket
        owner_ticket_granting_ticket
        lambda do
          processor.process(params, cookies, user_agent)
        end.should change(CASinoCore::Model::TicketGrantingTicket, :count).by(-1)
      end

      it 'deletes the ticket-granting ticket' do
        processor.process(params, cookies, user_agent)
        CASinoCore::Model::TicketGrantingTicket.where(id: params[:id]).length.should == 0
      end

      it 'calls the #ticket_deleted method on the listener' do
        listener.should_receive(:ticket_deleted).with(no_args)
        processor.process(params, cookies, user_agent)
      end
    end

    context 'with an invalid ticket-granting ticket' do
      let(:params) { { id: 99999 } }
      it 'does not delete a ticket-granting ticket' do
        owner_ticket_granting_ticket
        lambda do
          processor.process(params, cookies, user_agent)
        end.should_not change(CASinoCore::Model::TicketGrantingTicket, :count)
      end

      it 'calls the #ticket_not_found method on the listener' do
        listener.should_receive(:ticket_not_found).with(no_args)
        processor.process(params, cookies, user_agent)
      end
    end

    context 'when trying to delete ticket-granting ticket of another user' do
      let(:ticket_granting_ticket) { FactoryGirl.create :ticket_granting_ticket, username: 'other_user' }
      let(:params) { { id: ticket_granting_ticket.id } }

      it 'does not delete a ticket-granting ticket' do
        owner_ticket_granting_ticket
        ticket_granting_ticket
        lambda do
          processor.process(params, cookies, user_agent)
        end.should change(CASinoCore::Model::TicketGrantingTicket, :count).by(0)
      end

      it 'calls the #ticket_not_found method on the listener' do
        listener.should_receive(:ticket_not_found).with(no_args)
        processor.process(params, cookies, user_agent)
      end
    end
  end
end