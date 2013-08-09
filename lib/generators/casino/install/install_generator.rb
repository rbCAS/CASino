module CASino
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    # Explicit namespace needed for proper inflection.
    # Thor::Group does not use ActiveSupport's Inflector when programmatically
    # generating the namespace, so this would be to "c_a_sino" otherwise.
    namespace 'casino:install'

    class_option :migration,
        desc:'Skip generating migrations',
        type: :boolean,
        default: true

    class_option :check_old_install,
        desc:'Check for pre-existing installation of CASino v1.3 or lower',
        type: :boolean,
        default: true

    def check_for_old_installation
      return unless options['check_old_install']

      if old_casino_install?
        say "It looks like you already have an older version of CASino installed.\n", :yellow
        if yes?('Would you like to migrate your installation now?')
          generate 'casino:migrate', options['force'] ? '--force' : nil
        else
          say "OK, then. But the current version is not compatible with the " \
              "older version, so you'll have to handle the upgrade manually."
        end
        exit
      end
    end

    def install_migrations
      return unless options['migration']

      rake 'casino:install:migrations'
    end

    def copy_config_files
      copy_file 'cas.yml', 'config/cas.yml'
      copy_file 'casino_and_overrides.scss', 'app/assets/stylesheets/casino_and_overrides.scss'
    end

    def insert_assets_loader
      insert_into_file 'app/assets/javascripts/application.js', :after => %r{//= require +['"]?jquery_ujs['"]?} do
        "\n//= require casino"
      end
    end

    def insert_engine_routes
      route "mount CASino::Engine => '/', :as => 'casino'"
    end

    def show_readme
      readme 'README'
    end

    private
    def old_casino_install?
      ActiveRecord::Base.connection.table_exists? 'login_tickets'
    end
  end
end
