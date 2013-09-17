module CASino
  class Listener

    # include helpers to have the route path methods (like sessions_path)
    include CASino::Engine.routes.url_helpers

    def initialize(controller)
      @controller = controller
    end

    protected
    def assign(name, value)
      @controller.instance_variable_set("@#{name}", value)
    end
  end
end
