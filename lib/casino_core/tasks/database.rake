require 'erb'
require 'yaml'
require 'logger'
require 'active_record'

namespace :casino_core do
  namespace :db do 
    task :environment do
      BASE_DIR = if Gem.loaded_specs['casino_core'].nil?
          Dir.pwd
        else
          Gem.loaded_specs['casino_core'].full_gem_path
        end
      DATABASE_ENV = ENV['DATABASE_ENV'] || ENV['RAILS_ENV'] || 'development'
      ActiveRecord::Migrator.migrations_paths = File.join(BASE_DIR, 'db', 'migrate')
      SCHEMA_PATH = ENV['SCHEMA'] || File.join(BASE_DIR, 'db', 'schema.rb')
    end

    task :configuration => :environment do
      CASinoCore.setup DATABASE_ENV
      ActiveRecord::Base.logger = CASinoCore::Settings.logger
    end

    desc 'Migrate the database (options: VERSION=x, VERBOSE=false)'
    task :migrate => :configuration do
      ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
      ActiveRecord::Migrator.migrate(ActiveRecord::Migrator.migrations_paths, ENV["VERSION"] ? ENV["VERSION"].to_i : nil) do |migration|
        ENV["SCOPE"].blank? || (ENV["SCOPE"] == migration.scope)
      end
    end

    desc 'Rolls the schema back to the previous version (specify steps w/ STEP=n).'
    task :rollback => :configuration do
      step = ENV['STEP'] ? ENV['STEP'].to_i : 1
      ActiveRecord::Migrator.rollback(ActiveRecord::Migrator.migrations_paths, step)
    end

    namespace :schema do
      desc 'Create a db/schema.rb file that can be portably used against any DB supported by AR'
      task :dump => :configuration do
        require 'active_record/schema_dumper'
        File.open(SCHEMA_PATH, "w:utf-8") do |file|
          ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
        end
      end

      desc 'Load a schema.rb file into the database'
      task :load => :configuration do
        if File.exists?(SCHEMA_PATH)
          load(SCHEMA_PATH)
        else
          abort %{#{SCHEMA_PATH} doesn't exist yet.}
        end
      end
    end
  end
end
