module FeatureHelpers
  def in_browser(name)
    original_browser = Capybara.session_name
    Capybara.session_name = name
    yield
    Capybara.session_name = original_browser
  end

  def sign_in(options = {})
    visit login_path
    fill_in 'username', with: options[:username] || 'testuser'
    fill_in 'password', with: options[:password] || 'foobar123'
    click_button 'Login'
  end
end

RSpec.configure do |config|
  config.include FeatureHelpers, type: :feature
end
