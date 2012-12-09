require 'spec_helper'

describe CASinoCore::Processor::LegacyValidator do
  describe '#process' do
    let(:listener) { Object.new }
    let(:processor) { described_class.new(listener) }
    let(:user_agent) { 'TestBrowser 1.0' }
    let(:ticket_granting_ticket) {
      CASinoCore::Model::TicketGrantingTicket.create!({
        ticket: 'TGC-HXdkW233TsRtiqYGq4b8U7',
        username: 'test',
        extra_attributes: nil,
        user_agent: user_agent
      })
    }
    let(:service) { 'https://example.com/cas-service' }
    let(:service_ticket) { ticket_granting_ticket.service_tickets.create! ticket: 'ST-2nOcXx56dtPTsB069yYf0h', service: service }
    let(:parameters) { { service: service, ticket: service_ticket.ticket }}

    before(:each) do
      listener.stub(:validation_failed)
      listener.stub(:validation_succeeded)
    end

    context 'with an unconsumed service ticket' do
      context 'without renew flag' do
        it 'consumes the service ticket' do
          processor.process(parameters)
          service_ticket.reload
          service_ticket.consumed.should == true
        end

        it 'calls the #validation_succeeded method on the listener' do
          listener.should_receive(:validation_succeeded).with("yes\ntest\n")
          processor.process(parameters)
        end
      end

      context 'with renew flag' do
        let(:parameters) { { service: service, ticket: service_ticket.ticket, renew: 'true' }}

        context 'with a service ticket without issued_from_credentials flag' do
          it 'consumes the service ticket' do
            processor.process(parameters)
            service_ticket.reload
            service_ticket.consumed.should == true
          end

          it 'calls the #validation_failed method on the listener' do
            listener.should_receive(:validation_failed).with("no\n\n")
            processor.process(parameters)
          end
        end

        context 'with a service ticket with issued_from_credentials flag' do
          before(:each) do
            service_ticket.issued_from_credentials = true
            service_ticket.save!
          end

          it 'consumes the service ticket' do
            processor.process(parameters)
            service_ticket.reload
            service_ticket.consumed.should == true
          end

          it 'calls the #validation_succeeded method on the listener' do
            listener.should_receive(:validation_succeeded).with("yes\ntest\n")
            processor.process(parameters)
          end
        end
      end
    end

    context 'with a consumed service ticket' do
      before(:each) do
        service_ticket.consumed = true
        service_ticket.save!
      end

      it 'calls the #validation_failed method on the listener' do
        listener.should_receive(:validation_failed).with("no\n\n")
        processor.process(parameters)
      end
    end
  end
end
