module CASinoCore
  autoload :Authenticator, 'casino_core/authenticator.rb'
  autoload :RakeTasks, 'casino_core/rake_tasks.rb'

  require 'casino_core/railtie' if defined?(Rails)
end
