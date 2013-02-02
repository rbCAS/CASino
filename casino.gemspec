# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'casino/version'

Gem::Specification.new do |s|
  s.name        = 'casino'
  s.version     = CASino::VERSION
  s.authors     = ['Nils Caspar']
  s.email       = ['ncaspar@me.com']
  s.homepage    = 'http://rbcas.org/'
  s.license     = 'MIT'
  s.summary     = 'A simple CAS server written in Ruby using the Rails framework.'
  s.description = 'CASino is a simple CAS (Central Authentication Service) server using CASinoCore as its backend.'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'rspec', '~> 2.12'
  s.add_development_dependency 'rspec-rails', '~> 2.0'
  s.add_development_dependency 'simplecov', '~> 0.7'
  s.add_development_dependency 'sqlite3', '~> 1.3'

  s.add_runtime_dependency 'rails', '~> 3.2.9'
  s.add_runtime_dependency 'jquery-rails', '~> 2.1'
  s.add_runtime_dependency 'casino_core', '~> 1.2.0'
end
