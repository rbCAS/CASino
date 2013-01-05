require 'casino_core/model'

class CASinoCore::Model::ServiceRule < ActiveRecord::Base
  attr_accessible :enabled, :order, :name, :url, :regex
end
