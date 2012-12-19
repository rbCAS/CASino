require 'spec_helper'

describe CASinoCore::Processor::SessionDestroyer do
  describe '#process' do
    let(:listener) { Object.new }
    let(:processor) { described_class.new(listener) }
    let(:user_agent) { 'TestBrowser 1.0' }
    let(:owner_ticket_granting_ticket) {
      CASinoCore::Model::TicketGrantingTicket.create!({
        ticket: 'TGC-ocCudGzZjJtrvOXJ485mt3',
        username: 'test',
        extra_attributes: nil,
        user_agent: user_agent
      })
    }
    let(:cookies) { { tgt: owner_ticket_granting_ticket.ticket } }

    before(:each) do
      listener.stub(:ticket_deleted)
      listener.stub(:ticket_not_found)
    end

    context 'with an existing ticket-granting ticket' do
      let(:ticket_granting_ticket) {
        CASinoCore::Model::TicketGrantingTicket.create!({
          ticket: 'TGC-HXdkW233TsRtiqYGq4b8U7',
          username: 'test',
          extra_attributes: nil,
          user_agent: user_agent
        })
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

    context 'with an invlaid ticket-granting ticket' do
      let(:params) { { id: 99999 } }
      it 'does not delete a ticket-granting ticket' do
        owner_ticket_granting_ticket
        lambda do
          processor.process(params, cookies, user_agent)
        end.should change(CASinoCore::Model::TicketGrantingTicket, :count).by(0)
      end

      it 'calls the #ticket_not_found method on the listener' do
        listener.should_receive(:ticket_not_found).with(no_args)
        processor.process(params, cookies, user_agent)
      end
    end

    context 'when trying to delete ticket-granting ticket of another user' do
      let(:ticket_granting_ticket) {
        CASinoCore::Model::TicketGrantingTicket.create!({
          ticket: 'TGC-HXdkW233TsRtiqYGq4b8U7',
          username: 'this_is_another_user',
          extra_attributes: nil,
          user_agent: user_agent
        })
      }
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