RSpec.configure do |config|
  config.before(:each) do
    CASinoCore.setup ENV['RAILS_ENV']
    CASinoCore::Settings.logger.level = ::Logger::Severity::UNKNOWN
  end
end