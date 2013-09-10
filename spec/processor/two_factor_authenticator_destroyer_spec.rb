require 'spec_helper'

describe CASino::TwoFactorAuthenticatorDestroyerProcessor do
  describe '#process' do
    let(:listener) { Object.new }
    let(:processor) { described_class.new(listener) }
    let(:cookies) { { tgt: tgt } }

    before(:each) do
      listener.stub(:user_not_logged_in)
      listener.stub(:two_factor_authenticator_destroyed)
      listener.stub(:invalid_two_factor_authenticator)
    end

    context 'with an existing ticket-granting ticket' do
      let(:ticket_granting_ticket) { FactoryGirl.create :ticket_granting_ticket }
      let(:user) { ticket_granting_ticket.user }
      let(:tgt) { ticket_granting_ticket.ticket }
      let(:user_agent) { ticket_granting_ticket.user_agent }
      let(:params) { { id: two_factor_authenticator.id } }

      context 'with a valid two-factor authenticator' do
        let!(:two_factor_authenticator) { FactoryGirl.create :two_factor_authenticator, user: user }

        it 'calls the #two_factor_authenticator_destroyed method on the listener' do
          listener.should_receive(:two_factor_authenticator_destroyed).with(no_args)
          processor.process(params, cookies, user_agent)
        end

        it 'deletes the two-factor authenticator' do
          processor.process(params, cookies, user_agent)
          lambda do
            two_factor_authenticator.reload
          end.should raise_error(ActiveRecord::RecordNotFound)
        end

        it 'does not delete other two-factor authenticators' do
          other = FactoryGirl.create :two_factor_authenticator
          lambda do
            processor.process(params, cookies, user_agent)
          end.should change(CASino::TwoFactorAuthenticator, :count).by(-1)
        end
      end

      context 'with a two-factor authenticator of another user' do
        let!(:two_factor_authenticator) { FactoryGirl.create :two_factor_authenticator }

        it 'calls the #invalid_two_factor_authenticator method on the listener' do
          listener.should_receive(:invalid_two_factor_authenticator).with(no_args)
          processor.process(params, cookies, user_agent)
        end

        it 'does not delete two-factor authenticators' do
          lambda do
            processor.process(params, cookies, user_agent)
          end.should_not change(CASino::TwoFactorAuthenticator, :count)
        end
      end
    end

    context 'with an invalid ticket-granting ticket' do
      let(:params) { {} }
      let(:tgt) { 'TGT-lalala' }
      let(:user_agent) { 'TestBrowser 1.0' }
      it 'calls the #user_not_logged_in method on the listener' do
        listener.should_receive(:user_not_logged_in).with(no_args)
        processor.process(params, cookies, user_agent)
      end
    end
  end
end