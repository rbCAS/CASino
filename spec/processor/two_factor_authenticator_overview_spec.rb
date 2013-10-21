require 'spec_helper'

describe CASino::TwoFactorAuthenticatorOverviewProcessor do
  describe '#process' do
    let(:listener) { Object.new }
    let(:processor) { described_class.new(listener) }
    let(:cookies) { { tgt: tgt } }

    before(:each) do
      listener.stub(:user_not_logged_in)
      listener.stub(:two_factor_authenticators_found)
    end

    context 'with an existing ticket-granting ticket' do
      let(:ticket_granting_ticket) { FactoryGirl.create :ticket_granting_ticket }
      let(:user) { ticket_granting_ticket.user }
      let(:tgt) { ticket_granting_ticket.ticket }
      let(:user_agent) { ticket_granting_ticket.user_agent }

      context 'without a two-factor authenticator registered' do
        it 'calls the #two_factor_authenticators_found method on the listener' do
          listener.should_receive(:two_factor_authenticators_found).with([])
          processor.process(cookies, user_agent)
        end
      end

      context 'with an inactive two-factor authenticator' do
        let!(:two_factor_authenticator) { FactoryGirl.create :two_factor_authenticator, :inactive, user: user }

        it 'does not include the inactive authenticator' do
          listener.should_receive(:two_factor_authenticators_found).with([])
          processor.process(cookies, user_agent)
        end
      end

      context 'with a two-factor authenticator registered' do
        let(:two_factor_authenticator) { FactoryGirl.create :two_factor_authenticator, user: user }
        let!(:other_two_factor_authenticator) { FactoryGirl.create :two_factor_authenticator }

        it 'calls the #two_factor_authenticators_found method on the listener' do
          listener.should_receive(:two_factor_authenticators_found).with([two_factor_authenticator])
          processor.process(cookies, user_agent)
        end
      end
    end

    context 'with an invalid ticket-granting ticket' do
      let(:tgt) { 'TGT-lalala' }
      let(:user_agent) { 'TestBrowser 1.0' }
      it 'calls the #user_not_logged_in method on the listener' do
        listener.should_receive(:user_not_logged_in).with(no_args)
        processor.process(cookies, user_agent)
      end
    end
  end
end