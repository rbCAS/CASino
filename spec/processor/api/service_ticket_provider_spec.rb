require 'spec_helper'

describe CASino::API::ServiceTicketProviderProcessor do
  describe '#process' do
    let(:listener) { Object.new }
    let(:processor) { described_class.new(listener) }

    let(:service) { 'http://example.org/' }
    let(:parameters) { { service: service } }

    context 'with an invalid ticket-granting ticket' do
      let(:ticket_granting_ticket) { 'TGT-INVALID' }

      it 'calls the #invalid_tgt_via_api method on the listener' do
        listener.should_receive(:invalid_ticket_granting_ticket_via_api)
        processor.process(ticket_granting_ticket, parameters).should be_false
      end
    end

    context 'with a valid ticket-granting ticket' do
      let(:ticket_granting_ticket) { FactoryGirl.create(:ticket_granting_ticket) }
      let(:ticket) { ticket_granting_ticket.ticket }
      let(:user_agent) { ticket_granting_ticket.user_agent }

      context 'with a not allowed service' do
        before(:each) do
          FactoryGirl.create :service_rule, :regex, url: '^https://.*'
        end
        let(:service) { 'http://www.example.org/' }

        it 'calls the #service_not_allowed method on the listener' do
          listener.should_receive(:service_not_allowed_via_api).with(service)
          processor.process(ticket, parameters, user_agent)
        end
      end

      it 'calls the #granted_service_ticket_via_api method on the listener' do
        listener.should_receive(:granted_service_ticket_via_api).with(/^ST\-/)
        processor.process(ticket, parameters, user_agent)
      end

      it 'generates a ticket-granting ticket' do
        listener.should_receive(:granted_service_ticket_via_api).with(/^ST\-/)
        expect {
          processor.process(ticket, parameters, user_agent)
        }.to change(CASino::ServiceTicket, :count).by(1)
      end

      context 'without a service' do
        let(:parameters) { { } }

        it 'calls the #no_service_provided_via_api method on the listener' do
          listener.should_receive(:no_service_provided_via_api)
          processor.process(ticket, parameters, user_agent)
        end
      end

    end
  end
end

