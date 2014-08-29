require 'spec_helper'

describe CASino::TwoFactorAuthenticatorsController do
  let(:params) { { } }
  let(:request_options) { params.merge(use_route: :casino) }

  describe 'GET "new"' do
    context 'with an existing ticket-granting ticket' do
      let(:ticket_granting_ticket) { FactoryGirl.create :ticket_granting_ticket }
      let(:user) { ticket_granting_ticket.user }
      let(:user_agent) { ticket_granting_ticket.user_agent }

      before(:each) do
        sign_in(ticket_granting_ticket)
      end

      it 'creates exactly one authenticator' do
        lambda do
          get :new, request_options
        end.should change(CASino::TwoFactorAuthenticator, :count).by(1)
      end

      it 'assigns the two_factor_authenticator' do
        get :new, request_options
        assigns(:two_factor_authenticator).should be_kind_of(CASino::TwoFactorAuthenticator)
      end

      it 'creates an inactive two-factor authenticator' do
        get :new, request_options
        CASino::TwoFactorAuthenticator.last.should_not be_active
      end

      it 'renders the new template' do
        get :new, request_options
        response.should render_template(:new)
      end
    end

    context 'without a ticket-granting ticket' do
      it 'redirects to the login page' do
        get :new, request_options
        response.should redirect_to('/login')
      end
    end
  end

  describe 'POST "create"' do
    it 'calls the process method of the TwoFactorAuthenticatorActivator' do
      CASino::TwoFactorAuthenticatorActivatorProcessor.any_instance.should_receive(:process) do
        @controller.render nothing: true
      end
      post :create, use_route: :casino
    end
  end

  describe 'DELETE "destroy"' do
    let(:id) { '123' }
    let(:tgt) { 'TGT-foobar' }
    it 'calls the process method of the TwoFactorAuthenticatorDestroyer processor' do
      request.cookies[:tgt] = tgt
      CASino::TwoFactorAuthenticatorDestroyerProcessor.any_instance.should_receive(:process) do |params, cookies, user_agent|
        params[:id].should == id
        cookies[:tgt].should == tgt
        user_agent.should == request.user_agent
        @controller.render nothing: true
      end
      delete :destroy, id:id, use_route: :casino
    end
  end
end
