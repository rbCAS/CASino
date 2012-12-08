# encoding: utf-8
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'casino_core'
CASinoCore.setup 'development'
CASinoCore::RakeTasks.load_tasks

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "casino_core"
  gem.homepage = "http://github.com/pencil/CASinoCore"
  gem.license = "MIT"
  gem.summary = "A CAS server core library."
  gem.description = gem.summary
  gem.email = "ncaspar@me.com"
  gem.authors = ["Nils Caspar"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'yard'
YARD::Rake::YardocTask.new do |t|
  t.files = FileList['lib/**/*.rb']
end

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task :default => :spec
