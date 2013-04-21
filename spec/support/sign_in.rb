def integration_sign_in(options = {})
  visit login_path
  fill_in 'username', with: options[:username] || 'testuser'
  fill_in 'password', with: options[:password] || 'foobar123'
  click_button 'Login'
end
