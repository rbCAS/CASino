module CASinoCore
  autoload :Authenticator, 'casino_core/authenticator.rb'
  autoload :Helper, 'casino_core/helper.rb'
  autoload :Model, 'casino_core/model.rb'
  autoload :Processor, 'casino_core/processor.rb'
  autoload :RakeTasks, 'casino_core/rake_tasks.rb'
  autoload :Settings, 'casino_core/settings.rb'

  require 'casino_core/railtie' if defined?(Rails)

  class << self
    def setup(environment = nil, options = {})
      @environment = environment || 'development'
      require 'active_record'
      require 'yaml'
      YAML::ENGINE.yamler = 'syck'
      ActiveRecord::Base.establish_connection YAML.load_file('config/database.yml')[@environment]

      config = YAML.load_file('config/cas.yml')[@environment].symbolize_keys
      recursive_symbolize_keys!(config)
      CASinoCore::Settings.init config
    end

    private
    def recursive_symbolize_keys! hash
      hash.symbolize_keys!
      hash.values.select{|v| v.is_a? Hash}.each{|h| recursive_symbolize_keys!(h)}
    end
  end
end
