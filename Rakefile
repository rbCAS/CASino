require 'bundler'
require 'rake'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'yard'

require 'casino_core'

task :default => :spec

CASinoCore::RakeTasks.load_tasks

YARD::Rake::YardocTask.new do |t|
  t.files = FileList['lib/**/*.rb']
end

desc 'Run all specs'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end
