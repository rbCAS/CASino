require 'casino'

module CASino
  class Engine < Rails::Engine
    isolate_namespace CASino

    initializer 'casino.assets' do
      require 'jquery-rails'
    end
  end
end
