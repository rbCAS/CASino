require 'casino_core'
require 'rails'

module CASinoCore
  class Railtie < Rails::Railtie
    rake_tasks do
      CASinoCore::RakeTasks.load_tasks
    end

    initializer "casino_core.load_configuration" do
      CASinoCore.setup Rails.env
    end
  end
end
