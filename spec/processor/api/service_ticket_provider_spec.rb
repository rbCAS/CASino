require 'spec_helper'

describe CASinoCore::Processor::API::ServiceTicketProvider do
  describe '#process' do
    let(:listener) { Object.new }
    let(:processor) { described_class.new(listener) }

    let(:service) { 'http://example.org/' }

    context 'with an invalid tgt' do
      let(:tgt) { 'TGT-INVALID' }

      it 'calls the #invalid_tgt_via_api method on the listener' do
        listener.should_receive(:invalid_tgt_via_api)
        processor.process(tgt, service).should be_false
      end
    end

    context 'with a valid tgt' do
      let(:tgt) { FactoryGirl.create(:ticket_granting_ticket, user_agent: nil) }

      it 'calls the #granted_service_ticket_via_api method on the listener' do
        listener.should_receive(:granted_service_ticket_via_api).with(/^ST\-/)
        processor.process(tgt.ticket, service)
      end

      it 'generates a ticket-granting ticket' do
        listener.should_receive(:granted_service_ticket_via_api).with(/^ST\-/)
        expect {
          processor.process(tgt.ticket, service)
        }.to change(CASinoCore::Model::ServiceTicket, :count).by(1)
      end
    end
  end
end

