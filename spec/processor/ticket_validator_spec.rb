require 'spec_helper'

[CASino::ServiceTicketValidatorProcessor, CASino::ProxyTicketValidatorProcessor].each do |class_under_test|
  describe class_under_test do
    describe '#process' do
      let(:listener) { Object.new }
      let(:processor) { described_class.new(listener) }
      let(:service_ticket) { FactoryGirl.create :service_ticket }
      let(:parameters) { { service: service_ticket.service, ticket: service_ticket.ticket }}
      let(:regex_failure) { /\A\<cas\:serviceResponse.*\n.*authenticationFailure/ }
      let(:regex_success) { /\A\<cas\:serviceResponse.*\n.*authenticationSuccess/ }

      before(:each) do
        listener.stub(:validation_failed)
        listener.stub(:validation_succeeded)
      end

      context 'without all required parameters' do
        [:ticket, :service].each do |missing_parameter|
          let(:invalid_parameters) { parameters.except(missing_parameter) }

          context "without '#{missing_parameter}'" do
            it 'calls the #validation_failed method on the listener' do
              listener.should_receive(:validation_failed).with(regex_failure)
              processor.process(invalid_parameters)
            end
          end
        end
      end

      context 'with an unconsumed service ticket' do
        context 'with extra attributes using strings as keys' do
          before(:each) do
            CASino::User.any_instance.stub(:extra_attributes).and_return({ "id" => 1234 })
          end

          after(:each) do
            CASino::User.any_instance.unstub(:extra_attributes)
          end

          it 'includes the extra attributes' do
            listener.should_receive(:validation_succeeded).with(/<cas\:id>1234<\/cas\:id\>/)
            processor.process(parameters)
          end
        end

        context 'issued from a long_term ticket-granting ticket' do
          before(:each) do
            tgt = service_ticket.ticket_granting_ticket
            tgt.long_term = true
            tgt.save!
          end

          it 'calls the #validation_succeeded method on the listener' do
            listener.should_receive(:validation_succeeded).with(
              /<cas\:longTermAuthenticationRequestTokenUsed>true<\/cas\:longTermAuthenticationRequestTokenUsed>/
            )
            processor.process(parameters)
          end
        end

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

        context 'with empty query values' do
          it 'calls the #validation_succeeded method on the listener' do
            listener.should_receive(:validation_succeeded).with(regex_success)
            processor.process(parameters.merge(service: "#{service_ticket.service}/?"))
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
          let(:pgt_url) { 'https://www.example.org' }
          let(:parameters_with_pgt_url) { parameters.merge pgtUrl: pgt_url }

          before(:each) do
            stub_request(:get, /#{pgt_url}\/\?pgtId=[^&]+&pgtIou=[^&]+/)
          end

          context 'not using https' do
            let(:pgt_url) { 'http://www.example.org' }

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
            proxy_granting_ticket = CASino::ProxyGrantingTicket.last
            WebMock.should have_requested(:get, 'https://www.example.org').with(query: {
              pgtId: proxy_granting_ticket.ticket,
              pgtIou: proxy_granting_ticket.iou
            })
          end

          context 'when callback server gives an error' do
            before(:each) do
              stub_request(:get, /#{pgt_url}.*/).to_return status: 404
            end

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

          context 'when callback server is unreachable' do
            before(:each) do
              stub_request(:get, /#{pgt_url}.*/).to_raise(Timeout::Error)
            end

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
end
