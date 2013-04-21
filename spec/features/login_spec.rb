require 'spec_helper'

describe 'Login' do
  include CASino::Engine.routes.url_helpers

  subject { page }

  context 'with valid username and password' do
    before { sign_in }

    it { should_not have_button('Login') }
    its(:current_path) { should == sessions_path }
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
