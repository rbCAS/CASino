require 'spec_helper'

describe 'Login' do
  include CASino::Engine.routes.url_helpers

  subject { page }

  context 'with valid username and password' do
    before { integration_sign_in }

    it { should have_link('Logout') }
  end

  context 'with invalid username' do
    before { integration_sign_in username: 'lalala', password: 'foobar123' }

    it { should have_button('Login') }
  end

  context 'with blank password' do
    before { integration_sign_in password: '' }

    it { should have_button('Login') }
  end
end
