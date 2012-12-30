require 'spec_helper'

describe CASinoCore::Processor::ProxyTicketValidator do
  let(:listener) { Object.new }
  let(:processor) { described_class.new(listener) }

  describe '#process' do
    let(:regex_success) { /\A<cas:serviceResponse.*\n.*authenticationSuccess/ }

    context 'with an unconsumed proxy ticket' do
      let(:ticket_granting_ticket) { FactoryGirl.create :ticket_granting_ticket }
      let(:service_ticket) { ticket_granting_ticket.service_tickets.create! ticket: 'ST-2nOcXx56dtPTsB069yYf0h', service: 'http://www.example.com/' }
      let(:proxy_granting_ticket) {
        service_ticket.proxy_granting_tickets.create! ticket: 'PGT-OIE42ZadV3B9VcaG2xMjAf', iou: 'PGTIOU-PYg4CCPQHNyyS9s6bJF6Rg', pgt_url: 'https://www.example.com/pgtUrl'
      }
      let(:proxy_service) { 'imaps://127.0.0.1:4578/' }
      let(:proxy_ticket) { proxy_granting_ticket.proxy_tickets.create! ticket: 'PT-8nA7vuxuNY7RcpVoaDvuZi', service: proxy_service }
      let(:parameters) { { ticket: proxy_ticket.ticket, service: proxy_service } }
      let(:regex_proxy) { /<cas:proxies>\s*<cas:proxy>https:\/\/www.example.com\/pgtUrl<\/cas:proxy>\s*<\/cas:proxies[>]/ }

      it 'calls the #validation_succeeded method on the listener' do
        listener.should_receive(:validation_succeeded).with(regex_success)
        processor.process(parameters)
      end

      it 'includes the proxy in the response' do
        listener.should_receive(:validation_succeeded).with(regex_proxy)
        processor.process(parameters)
      end

      context 'with an expired proxy ticket' do
        before(:each) do
          CASinoCore::Model::ProxyTicket.any_instance.stub(:expired?).and_return(true)
        end

        it 'calls the #validation_failed method on the listener' do
          listener.should_receive(:validation_failed)
          processor.process(parameters)
        end
      end

      context 'with an other service' do
        let(:parameters_with_other_service) { parameters.merge(service: 'this_is_another_service') }

        it 'calls the #validation_failed method on the listener' do
          listener.should_receive(:validation_failed)
          processor.process(parameters_with_other_service)
        end
      end

      context 'without an existing ticket' do
        let(:parameters_without_existing_ticket) { { ticket: 'PT-1234', service: 'https://www.example.com/' } }

        it 'calls the #validation_failed method on the listener' do
          listener.should_receive(:validation_failed)
          processor.process(parameters_without_existing_ticket)
        end
      end
    end
  end
end
