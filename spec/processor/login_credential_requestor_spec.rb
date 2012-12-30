require 'spec_helper'

describe CASinoCore::Processor::LoginCredentialRequestor do
  describe '#process' do
    let(:listener) { Object.new }
    let(:processor) { described_class.new(listener) }

    context 'when logged out' do
      it 'calls the #user_not_logged_in method on the listener' do
        listener.should_receive(:user_not_logged_in).with(kind_of(CASinoCore::Model::LoginTicket))
        processor.process
      end

      context 'with gateway parameter' do
        context 'with a service' do
          let(:service) { 'http://example.com/' }
          let(:params) { { service: service, gateway: 'true' } }

          it 'calls the #user_logged_in method on the listener' do
            listener.should_receive(:user_logged_in).with(service)
            processor.process(params)
          end
        end

        context 'without a service' do
          let(:params) { { gateway: 'true' } }

          it 'calls the #user_not_logged_in method on the listener' do
            listener.should_receive(:user_not_logged_in).with(kind_of(CASinoCore::Model::LoginTicket))
            processor.process
          end
        end
      end
    end

    context 'when logged in' do
      let(:ticket_granting_ticket) { FactoryGirl.create :ticket_granting_ticket }
      let(:user_agent) { ticket_granting_ticket.user_agent }
      let(:cookies) { { tgt: ticket_granting_ticket.ticket } }

      before(:each) do
        listener.stub(:user_logged_in)
      end

      context 'with a service' do
        let(:service) { 'http://example.com/' }
        let(:params) { { service: service } }

        it 'calls the #user_logged_in method on the listener' do
          listener.should_receive(:user_logged_in).with(/^#{service}\?ticket=ST\-/)
          processor.process(params, cookies, user_agent)
        end

        it 'generates a service ticket' do
          lambda do
            processor.process(params, cookies, user_agent)
          end.should change(CASinoCore::Model::ServiceTicket, :count).by(1)
        end

        context 'with renew parameter' do
          it 'calls the #user_not_logged_in method on the listener' do
            listener.should_receive(:user_not_logged_in).with(kind_of(CASinoCore::Model::LoginTicket))
            processor.process(params.merge({ renew: 'true' }), cookies)
          end
        end
      end

      context 'without a service' do
        it 'calls the #user_logged_in method on the listener' do
          listener.should_receive(:user_logged_in).with(nil)
          processor.process(nil, cookies, user_agent)
        end

        it 'does not generate a service ticket' do
          lambda do
            processor.process(nil, cookies, user_agent)
          end.should change(CASinoCore::Model::ServiceTicket, :count).by(0)
        end

        context 'with a changed browser' do
          let(:user_agent) { 'FooBar 1.0' }

          it 'calls the #user_not_logged_in method on the listener' do
            listener.should_receive(:user_not_logged_in).with(kind_of(CASinoCore::Model::LoginTicket))
            processor.process(nil, cookies, user_agent)
          end
        end
      end
    end
  end
end
