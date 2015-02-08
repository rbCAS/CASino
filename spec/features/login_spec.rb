require 'spec_helper'

describe 'Login' do
  include CASino::Engine.routes.url_helpers

  subject { page }

  context 'with two-factor authentication enabled' do
    before do
      in_browser(:other) do
        sign_in
        @totp = enable_two_factor_authentication
      end
    end

    context 'with valid username and password' do
      before { sign_in }

      it { should_not have_button('Login') }
      it { should have_button('Continue') }
      its(:current_path) { should == login_path }

      context 'when filling in the correct otp' do
        before do
          fill_in :otp, with: @totp.now
          click_button 'Continue'
        end

        it { should_not have_button('Login') }
        it { should_not have_button('Continue') }
        its(:current_path) { should == sessions_path }
      end

      context 'when filling in an incorrect otp' do
        before do
          fill_in :otp, with: 'aaaaa'
          click_button 'Continue'
        end

        it { should have_text('The one-time password you entered is not correct') }
        it { should have_button('Continue') }
      end
    end
  end

  context 'with two-factor authentication disabled' do
    context 'with valid username and password' do
      before { sign_in }

      it { should_not have_button('Login') }
      its(:current_path) { should == sessions_path }
    end
  end

  context 'with invalid username' do
    before { sign_in username: 'lalala', password: 'foobar123' }

    it { should have_button('Login') }
    it { should have_text('Incorrect username or password') }
  end

  context 'with blank password' do
    before { sign_in password: '' }

    it { should have_button('Login') }
    it { should have_text('Incorrect username or password') }
  end
end
