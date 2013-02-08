require 'casino_core'

module Casino # CASino would lead to c_a_sino...
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def copy_initializer_file
      copy_file 'casino_core.rb', 'config/initializers/casino_core.rb'
    end

    def copy_config_files
      copy_file 'cas.yml', 'config/cas.yml'
      copy_file 'database.yml', 'config/database.yml'
      copy_file 'casino_and_overrides.scss', 'app/assets/stylesheets/casino_and_overrides.scss'
    end

    def insert_assets_loader
      insert_into_file 'app/assets/javascripts/application.js', :after => %r{//= require +['"]?jquery_ujs['"]?} do
        "\n//= require casino"
      end
    end

    def insert_engine_routes
      route "mount CASino::Engine => '/', :as => 'CASino'"
    end

    def remove_index_html
      remove_file 'public/index.html'
    end

    def show_readme
      readme 'README'
    end
  end
end
