require 'spec_helper'

describe CASino::SessionOverviewProcessor do
  describe '#process' do
    let(:listener) { Object.new }
    let(:processor) { described_class.new(listener) }
    let(:other_ticket_granting_ticket) { FactoryGirl.create :ticket_granting_ticket }
    let(:user) { other_ticket_granting_ticket.user }
    let(:user_agent) { other_ticket_granting_ticket.user_agent }
    let(:cookies) { { tgt: tgt } }

    before(:each) do
      listener.stub(:user_not_logged_in)
      listener.stub(:ticket_granting_tickets_found)
      other_ticket_granting_ticket
    end

    context 'with an existing ticket-granting ticket' do
      let(:ticket_granting_ticket) { FactoryGirl.create :ticket_granting_ticket, user: user }
      let(:tgt) { ticket_granting_ticket.ticket }
      it 'calls the #ticket_granting_tickets_found method on the listener' do
        listener.should_receive(:ticket_granting_tickets_found) do |tickets|
          tickets.length.should == 2
        end
        processor.process(cookies, user_agent)
      end
    end

    context 'with a ticket-granting ticket with same username but different authenticator' do
      let(:ticket_granting_ticket) { FactoryGirl.create :ticket_granting_ticket }
      let(:tgt) { ticket_granting_ticket.ticket }

      it 'calls the #ticket_granting_tickets_found method on the listener' do
        listener.should_receive(:ticket_granting_tickets_found) do |tickets|
          tickets.length.should == 1
        end
        processor.process(cookies, user_agent)
      end
    end

    context 'with an invalid ticket-granting ticket' do
      let(:tgt) { 'TGT-lalala' }
      it 'calls the #user_not_logged_in method on the listener' do
        listener.should_receive(:user_not_logged_in).with(no_args)
        processor.process(cookies, user_agent)
      end
    end
  end
end