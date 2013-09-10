require 'active_support/inflector'
require 'active_record'

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
      root_path = options[:application_root] || '.'

      config = YAML.load_file(File.join(root_path, 'config/cas.yml'))[@environment].symbolize_keys
      recursive_symbolize_keys!(config)
      CASinoCore::Settings.init config
    end

    private
    def recursive_symbolize_keys! hash
      # ugly, ugly, ugly
      # TODO refactor!
      hash.symbolize_keys!
      hash.values.select{|v| v.is_a? Hash}.each{|h| recursive_symbolize_keys!(h)}
      hash.values.select{|v| v.is_a? Array}.each{|a| a.select{|v| v.is_a? Hash}.each{|h| recursive_symbolize_keys!(h)}}
    end
  end
end

ActiveSupport::Inflector.inflections do |inflect|
  inflect.acronym 'CAS'
  inflect.acronym 'CASino'
end
