# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'casino_core/version'

Gem::Specification.new do |s|
  s.name        = 'casino_core'
  s.version     = CASinoCore::VERSION
  s.authors     = ['Nils Caspar']
  s.email       = ['ncaspar@me.com']
  s.homepage    = 'http://rbcas.org/'
  s.license     = 'MIT'
  s.summary     = 'A CAS server core library.'
  s.description = 'CASinoCore is a CAS server library. It can be used by other projects to build a fully functional CAS server.'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.signing_key   = '~/.gem/casino-private_key.pem'
  s.cert_chain    = ['casino-public_cert.pem']

  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'rspec', '~> 2.12'
  s.add_development_dependency 'simplecov', '~> 0.7'
  s.add_development_dependency 'sqlite3', '~> 1.3'
  s.add_development_dependency 'database_cleaner', '~> 0.9'
  s.add_development_dependency 'webmock', '~> 1.9'
  s.add_development_dependency 'nokogiri', '~> 1.5'
  s.add_development_dependency 'factory_girl', '~> 4.1'
  s.add_development_dependency 'yard', '~> 0.8'

  s.add_runtime_dependency 'activerecord', '~> 3.2.9'
  s.add_runtime_dependency 'addressable', '~> 2.3'
  s.add_runtime_dependency 'terminal-table', '~> 1.4'
  s.add_runtime_dependency 'useragent', '~> 0.4'
end

