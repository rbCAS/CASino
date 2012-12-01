namespace :casino_core do
  namespace :db do 
    desc 'Migrate the database (options: VERSION=x, VERBOSE=false)'
    task :migrate do
      puts 'Migrate...'
    end
  end
end
