namespace :casino_core do
  namespace :db do 
    task :environment do
      DATABASE_ENV = ENV['DATABASE_ENV'] || ENV['RAILS_ENV'] || 'development'
      MIGRATIONS_DIR = File.join(Gem.loaded_specs['casino_core'].full_gem_path, 'db', 'migrate')
    end

    task :configuration => :environment do
      @config = YAML.load_file('config/database.yml')[DATABASE_ENV]
    end

    desc 'Migrate the database (options: VERSION=x, VERBOSE=false)'
    task :migrate => :configuration do
      puts File.expand_path MIGRATIONS_DIR
    end
  end
end
