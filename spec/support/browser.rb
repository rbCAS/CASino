def in_browser(name)
  original_browser = Capybara.session_name
  Capybara.session_name = name
  yield
  Capybara.session_name = original_browser
end
