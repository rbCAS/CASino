require 'active_support/inflector'
require 'active_record'

module CASinoCore
  autoload :Authenticator, 'casino_core/authenticator.rb'
end

ActiveSupport::Inflector.inflections do |inflect|
  inflect.acronym 'CAS'
  inflect.acronym 'CASino'
end
