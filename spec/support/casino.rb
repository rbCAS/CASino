require 'active_support/core_ext/hash/deep_dup'

RSpec.configure do |config|
  config.around(type: :controller) do
    self.routes = CASino::Engine.routes
  end

  config.before do
    @base_config = CASino.config.deep_dup
  end

  config.after do
    CASino.config.clear
    CASino.config.merge! @base_config
  end
end
