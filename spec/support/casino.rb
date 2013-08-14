require 'active_support/core_ext/hash/deep_dup'

RSpec.configure do |config|
  config.around(type: :controller) do
    self.routes = CASino::Engine.routes
  end
end
