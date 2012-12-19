require 'casino_core'
require 'rails'

module CASinoCore
  class Railtie < Rails::Railtie
    rake_tasks do
      CASinoCore::RakeTasks.load_tasks
    end

    initializer 'casino_core.load_configuration' do
      CASinoCore.setup Rails.env
    end

    initializer 'casino_core.setup_logger' do
      CASinoCore::Settings.logger = Rails.logger
  end
end
