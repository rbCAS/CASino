require 'spec_helper'

describe CASino::SecondFactorAuthenticationAcceptorProcessor do
  describe '#process' do
    let(:listener) { Object.new }
    let(:processor) { described_class.new(listener) }

    before(:each) do
      listener.stub(:user_not_logged_in)
      listener.stub(:invalid_one_time_password)
      listener.stub(:user_logged_in)
    end

    context 'with an existing ticket-granting ticket' do
      let(:ticket_granting_ticket) { FactoryGirl.create :ticket_granting_ticket, :awaiting_two_factor_authentication }
      let(:user) { ticket_granting_ticket.user }
      let(:tgt) { ticket_granting_ticket.ticket }
      let(:user_agent) { ticket_granting_ticket.user_agent }
      let(:otp) { '123456' }
      let(:service) { 'http://www.example.com/testing' }
      let(:params) { { tgt: tgt, otp: otp, service: service }}

      context 'with an active authenticator' do
        let!(:two_factor_authenticator) { FactoryGirl.create :two_factor_authenticator, user: user }

        context 'with a valid OTP' do
          before(:each) do
            ROTP::TOTP.any_instance.should_receive(:verify_with_drift).with(otp, 30).and_return(true)
          end

          it 'calls the `#user_logged_in` method an the listener' do
            listener.should_receive(:user_logged_in).with(/^#{service}\?ticket=ST\-/, /^TGC\-/)
            processor.process(params, user_agent)
          end

          it 'does activate the ticket-granting ticket' do
            processor.process(params, user_agent)
            ticket_granting_ticket.reload
            ticket_granting_ticket.should_not be_awaiting_two_factor_authentication
          end

          context 'with a long-term ticket-granting ticket' do
            before(:each) do
              ticket_granting_ticket.update_attributes! long_term: true
            end

            it 'calls the #user_logged_in method on the listener with an expiration date set' do
              listener.should_receive(:user_logged_in).with(/^#{service}\?ticket=ST\-/, /^TGC\-/, kind_of(Time))
              processor.process(params, user_agent)
            end
          end

          context 'with a not allowed service' do
            before(:each) do
              FactoryGirl.create :service_rule, :regex, url: '^https://.*'
            end
            let(:service) { 'http://www.example.org/' }

            it 'calls the #service_not_allowed method on the listener' do
              listener.should_receive(:service_not_allowed).with(service)
              processor.process(params.merge(service: service), user_agent)
            end
          end
        end

        context 'with an invalid OTP' do
          before(:each) do
            ROTP::TOTP.any_instance.should_receive(:verify_with_drift).with(otp, 30).and_return(false)
          end

          it 'calls the `#invalid_one_time_password` method an the listener' do
            listener.should_receive(:invalid_one_time_password).with(no_args)
            processor.process(params, user_agent)
          end

          it 'does not activate the ticket-granting ticket' do
            processor.process(params, user_agent)
            ticket_granting_ticket.reload
            ticket_granting_ticket.should be_awaiting_two_factor_authentication
          end
        end
      end
    end

    context 'with an invalid ticket-granting ticket' do
      let(:tgt) { 'TGT-lalala' }
      let(:user_agent) { 'TestBrowser 1.0' }
      it 'calls the #user_not_logged_in method on the listener' do
        listener.should_receive(:user_not_logged_in).with(no_args)
        processor.process({tgt: tgt}, user_agent)
      end
    end
  end
end