require 'spec_helper'

describe CASinoCore::Processor::API::ServiceTicketProvider do
  describe '#process' do
    let(:listener) { Object.new }
    let(:processor) { described_class.new(listener) }

    let(:default_parameters) { {service: 'http://example.org/'} }

    context 'with an invalid tgt' do
      let(:parameters) { default_parameters.merge(ticket_granting_ticket: 'TGT-INVALID') }

      it 'calls the #invalid_tgt_via_api method on the listener' do
        listener.should_receive(:invalid_ticket_granting_ticket_via_api)
        processor.process(parameters).should be_false
      end
    end

    context 'with a valid tgt' do
      let(:tgt) { FactoryGirl.create(:ticket_granting_ticket, user_agent: nil) }
      let(:parameters) { default_parameters.merge(ticket_granting_ticket: tgt.ticket) }

      it 'calls the #granted_service_ticket_via_api method on the listener' do
        listener.should_receive(:granted_service_ticket_via_api).with(/^ST\-/)
        processor.process(parameters)
      end

      it 'generates a ticket-granting ticket' do
        listener.should_receive(:granted_service_ticket_via_api).with(/^ST\-/)
        expect {
          processor.process(parameters)
        }.to change(CASinoCore::Model::ServiceTicket, :count).by(1)
      end

      context "without a service" do
        let(:parameters) { {ticket_granting_ticket: tgt.ticket} }

        it 'calls the #no_service_provided_via_api method on the listener' do
          listener.should_receive(:no_service_provided_via_api)
          processor.process(parameters)
        end
      end

    end
  end
end

