require 'yaml'
require 'logger'
require 'active_record'

namespace :casino_core do
  namespace :db do 
    task :environment do
      BASE_DIR = if Gem.loaded_specs['casino_core'].nil?
          ''
        else
          Gem.loaded_specs['casino_core'].full_gem_path
        end
      DATABASE_ENV = ENV['DATABASE_ENV'] || ENV['RAILS_ENV'] || 'development'
      MIGRATIONS_DIR = File.join(BASE_DIR, 'db', 'migrate')
    end

    task :configuration => :environment do
      @config = YAML.load_file('config/database.yml')[DATABASE_ENV]
    end

    task :configure_connection => :configuration do
      ActiveRecord::Base.establish_connection @config
      ActiveRecord::Base.logger = Logger.new STDOUT if @config['logger']
    end

    desc 'Migrate the database (options: VERSION=x, VERBOSE=false)'
    task :migrate => :configure_connection do
      ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
      ActiveRecord::Migrator.migrate(ActiveRecord::Migrator.migrations_paths, ENV["VERSION"] ? ENV["VERSION"].to_i : nil) do |migration|
        ENV["SCOPE"].blank? || (ENV["SCOPE"] == migration.scope)
      end
    end

    desc 'Rolls the schema back to the previous version (specify steps w/ STEP=n).'
    task :rollback => [:environment, :load_config] do
      step = ENV['STEP'] ? ENV['STEP'].to_i : 1
      ActiveRecord::Migrator.rollback(ActiveRecord::Migrator.migrations_paths, step)
    end
  end
end
