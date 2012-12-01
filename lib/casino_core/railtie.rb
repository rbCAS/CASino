require 'casino_core'
require 'rails'

module CASinoCore
  class Railtie < Rails::Railtie
    rake_tasks do
      puts 'foo'
      CASinoCore::RakeTasks.load_tasks
    end
  end
end
