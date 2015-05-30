require 'spec_helper'

describe CASino::TwoFactorAuthenticatorsController do
  include CASino::Engine.routes.url_helpers
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

      context 'with a really long service name' do
        before(:each) do
          CASino.config.frontend[:sso_name] = 'Na' * 200
        end

        render_views

        it 'renders the new template' do
          get :new, request_options
          response.should render_template(:new)
        end
      end
    end

    context 'without a ticket-granting ticket' do
      it 'redirects to the login page' do
        get :new, request_options
        response.should redirect_to(login_path)
      end
    end
  end

  describe 'POST "create"' do
    context 'with an existing ticket-granting ticket' do
      let(:ticket_granting_ticket) { FactoryGirl.create :ticket_granting_ticket }
      let(:user) { ticket_granting_ticket.user }
      let(:id) { two_factor_authenticator.id }
      let(:otp) { '123456' }
      let(:params) { { otp: otp, id: id } }

      before(:each) do
        sign_in(ticket_granting_ticket)
      end

      context 'with an invalid authenticator' do
        context 'with an expired authenticator' do
          let(:two_factor_authenticator) { FactoryGirl.create :two_factor_authenticator, :inactive, user: user }

          before(:each) do
            two_factor_authenticator.created_at = 10.hours.ago
            two_factor_authenticator.save!
          end

          it 'redirects to the two-factor authenticator new page' do
            post :create, request_options
            response.should redirect_to(new_two_factor_authenticator_path)
          end

          it 'adds a error message' do
            post :create, request_options
            flash[:error].should == I18n.t('two_factor_authenticators.invalid_two_factor_authenticator')
          end
        end

        context 'with a authenticator of another user' do
          let(:two_factor_authenticator) { FactoryGirl.create :two_factor_authenticator, :inactive }

          before(:each) do
            two_factor_authenticator.created_at = 10.hours.ago
            two_factor_authenticator.save!
          end

          it 'redirects to the two-factor authenticator new page' do
            post :create, request_options
            response.should redirect_to(new_two_factor_authenticator_path)
          end
        end
      end

      context 'with a valid authenticator' do
        let(:two_factor_authenticator) { FactoryGirl.create :two_factor_authenticator, :inactive, user: user }

        context 'with a valid OTP' do
          before(:each) do
            ROTP::TOTP.any_instance.should_receive(:verify_with_drift).with(otp, 30).and_return(true)
          end

          it 'redirects to the session overview' do
            post :create, request_options
            response.should redirect_to(sessions_path)
          end

          it 'adds a notice' do
            post :create, request_options
            flash[:notice].should == I18n.t('two_factor_authenticators.successfully_activated')
          end

          it 'does activate the authenticator' do
            post :create, request_options
            two_factor_authenticator.reload.should be_active
          end

          context 'when another two-factor authenticator was active' do
            let!(:other_two_factor_authenticator) { FactoryGirl.create :two_factor_authenticator, user: user }

            it 'does activate the authenticator' do
              post :create, request_options
              two_factor_authenticator.reload.should be_active
            end

            it 'does delete the other authenticator' do
              post :create, request_options
              lambda do
                other_two_factor_authenticator.reload
              end.should raise_error(ActiveRecord::RecordNotFound)
            end
          end

        end

        context 'with an invalid OTP' do
          before(:each) do
            ROTP::TOTP.any_instance.should_receive(:verify_with_drift).with(otp, 30).and_return(false)
          end

          it 'rerenders the new page' do
            post :create, request_options
            response.should render_template(:new)
          end

          it 'adds a error message' do
            post :create, request_options
            flash[:error].should == I18n.t('two_factor_authenticators.invalid_one_time_password')
          end

          it 'assigns the two-factor authenticator' do
            post :create, request_options
            assigns(:two_factor_authenticator).should be_kind_of(CASino::TwoFactorAuthenticator)
          end

          it 'does not activate the authenticator' do
            post :create, request_options
            two_factor_authenticator.reload.should_not be_active
          end
        end
      end
    end

    context 'without a ticket-granting ticket' do
      it 'redirects to the login page' do
        post :create, request_options
        response.should redirect_to(login_path)
      end
    end
  end

  describe 'DELETE "destroy"' do
    context 'with an existing ticket-granting ticket' do
      let(:ticket_granting_ticket) { FactoryGirl.create :ticket_granting_ticket }
      let(:user) { ticket_granting_ticket.user }
      let(:params) { { id: two_factor_authenticator.id } }

      before(:each) do
        sign_in(ticket_granting_ticket)
      end

      context 'with a valid two-factor authenticator' do
        let!(:two_factor_authenticator) { FactoryGirl.create :two_factor_authenticator, user: user }
        let!(:other_two_factor_authenticator) { FactoryGirl.create :two_factor_authenticator }

        it 'redirects to the session overview' do
          delete :destroy, request_options
          response.should redirect_to(sessions_path)
        end

        it 'adds a notice' do
          delete :destroy, request_options
          flash[:notice].should == I18n.t('two_factor_authenticators.successfully_deleted')
        end

        it 'deletes the two-factor authenticator' do
          delete :destroy, request_options
          lambda do
            two_factor_authenticator.reload
          end.should raise_error(ActiveRecord::RecordNotFound)
        end

        it 'does not delete other two-factor authenticators' do
          lambda do
            delete :destroy, request_options
          end.should change(CASino::TwoFactorAuthenticator, :count).by(-1)
        end
      end

      context 'with a two-factor authenticator of another user' do
        let!(:two_factor_authenticator) { FactoryGirl.create :two_factor_authenticator }

        it 'redirects to the session overview' do
          delete :destroy, request_options
          response.should redirect_to(sessions_path)
        end

        it 'does not delete two-factor authenticators' do
          lambda do
            delete :destroy, request_options
          end.should_not change(CASino::TwoFactorAuthenticator, :count)
        end
      end
    end

    context 'without a ticket-granting ticket' do
      it 'redirects to the login page' do
        delete :destroy, request_options
        response.should redirect_to(login_path)
      end
    end
  end
end
