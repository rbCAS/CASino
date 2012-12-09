require 'spec_helper'

describe CASinoCore::Processor::SessionDestroyer do
  describe '#process' do
    let(:listener) { Object.new }
    let(:processor) { described_class.new(listener) }
    let(:user_agent) { 'TestBrowser 1.0' }
    let(:other_ticket_granting_ticket) {
      CASinoCore::Model::TicketGrantingTicket.create!({
        ticket: 'TGC-ocCudGzZjJtrvOXJ485mt3',
        username: 'test',
        extra_attributes: nil,
        user_agent: user_agent
      })
    }

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
      let(:tgt) { ticket_granting_ticket.ticket }

      it 'deletes only one ticket-granting ticket' do
        ticket_granting_ticket
        other_ticket_granting_ticket
        lambda do
          processor.process(tgt)
        end.should change(CASinoCore::Model::TicketGrantingTicket, :count).by(-1)
      end

      it 'deletes the ticket-granting ticket' do
        processor.process(tgt)
        CASinoCore::Model::TicketGrantingTicket.where(ticket: tgt).length.should == 0
      end

      it 'calls the #ticket_deleted method on the listener' do
        listener.should_receive(:ticket_deleted).with(no_args)
        processor.process(tgt)
      end
    end

    context 'with an invlaid ticket-granting ticket' do
      let(:tgt) { 'TGT-lalala' }

      it 'does not delete a ticket-granting ticket' do
        other_ticket_granting_ticket
        lambda do
          processor.process(tgt)
        end.should change(CASinoCore::Model::TicketGrantingTicket, :count).by(0)
      end

      it 'calls the #ticket_not_found method on the listener' do
        listener.should_receive(:ticket_not_found).with(no_args)
        processor.process(tgt)
      end
    end
  end
end