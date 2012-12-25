require 'spec_helper'

describe CASinoCore::Processor::ServiceTicketValidator do
  describe '#process' do
    let(:listener) { Object.new }
    let(:processor) { described_class.new(listener) }
    let(:user_agent) { 'TestBrowser 1.0' }
    let(:ticket_granting_ticket) {
      CASinoCore::Model::TicketGrantingTicket.create!({
        ticket: 'TGC-HXdkW233TsRtiqYGq4b8U7',
        username: 'test',
        extra_attributes: { name: "Example User", roles: ['User', 'Admin'] },
        user_agent: user_agent
      })
    }
    let(:service) { 'https://www.example.com/cas-service' }
    let(:service_ticket) { ticket_granting_ticket.service_tickets.create! ticket: 'ST-2nOcXx56dtPTsB069yYf0h', service: service }
    let(:parameters) { { service: service, ticket: service_ticket.ticket }}

    let(:regex_failure) { /\A\<cas\:serviceResponse.*\n.*authenticationFailure/ }
    let(:regex_success) { /\A\<cas\:serviceResponse.*\n.*authenticationSuccess/ }

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
          listener.should_receive(:validation_succeeded).with(regex_success)
          processor.process(parameters)
        end
      end

      context 'with renew flag' do
        let(:parameters_with_renew) { parameters.merge renew: 'true' }

        context 'with a service ticket without issued_from_credentials flag' do
          it 'consumes the service ticket' do
            processor.process(parameters_with_renew)
            service_ticket.reload
            service_ticket.consumed.should == true
          end

          it 'calls the #validation_failed method on the listener' do
            listener.should_receive(:validation_failed).with(regex_failure)
            processor.process(parameters_with_renew)
          end
        end

        context 'with a service ticket with issued_from_credentials flag' do
          before(:each) do
            service_ticket.issued_from_credentials = true
            service_ticket.save!
          end

          it 'consumes the service ticket' do
            processor.process(parameters_with_renew)
            service_ticket.reload
            service_ticket.consumed.should == true
          end

          it 'calls the #validation_succeeded method on the listener' do
            listener.should_receive(:validation_succeeded).with(regex_success)
            processor.process(parameters_with_renew)
          end
        end
      end

      context 'with proxy-granting ticket callback server' do
        let(:parameters_with_pgt_url) { parameters.merge pgtUrl: "https://www.example.com" }

        before(:each) do
          stub_request(:get, /https:\/\/www\.example\.com\/\?pgtId=[^&]+&pgtIou=[^&]+/)
        end

        it 'calls the #validation_succeeded method on the listener' do
          listener.should_receive(:validation_succeeded).with(regex_success)
          processor.process(parameters_with_pgt_url)
        end

        it 'includes the PGTIOU in the response' do
          listener.should_receive(:validation_succeeded).with(/\<cas\:proxyGrantingTicket\>\n?\s*PGTIOU-.+/)
          processor.process(parameters_with_pgt_url)
        end

        it 'creates a proxy-granting ticket' do
          lambda do
            processor.process(parameters_with_pgt_url)
          end.should change(service_ticket.proxy_granting_tickets, :count).by(1)
        end

        it 'contacts the callback server' do
          processor.process(parameters_with_pgt_url)
          proxy_granting_ticket = CASinoCore::Model::ProxyGrantingTicket.last
          WebMock.should have_requested(:get, 'https://www.example.com').with(query: {
            pgtId: proxy_granting_ticket.ticket,
            pgtIou: proxy_granting_ticket.iou
          })
        end
      end

      context 'with proxy-granting ticket callback server not matching the service' do
        let(:parameters_with_pgt_url) { parameters.merge pgtUrl: 'https://www.example.org/' }

        it 'calls the #validation_succeeded method on the listener' do
          listener.should_receive(:validation_succeeded).with(regex_success)
          processor.process(parameters_with_pgt_url)
        end

        it 'does not create a proxy-granting ticket' do
          lambda do
            processor.process(parameters_with_pgt_url)
          end.should_not change(service_ticket.proxy_granting_tickets, :count)
        end
      end
    end

    context 'with a consumed service ticket' do
      before(:each) do
        service_ticket.consumed = true
        service_ticket.save!
      end

      it 'calls the #validation_failed method on the listener' do
        listener.should_receive(:validation_failed).with(regex_failure)
        processor.process(parameters)
      end
    end
  end
end
