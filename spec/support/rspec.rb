RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false
  config.run_all_when_everything_filtered = true
  config.filter_run focus: true
  config.order = 'random'
  config.infer_spec_type_from_file_location!

  config.mock_with :rspec do |mocks|
    mocks.yield_receiver_to_any_instance_implementation_blocks = false
    # TODO: we should maybe port existing tests to the new expect syntax
    mocks.syntax = [:should, :expect]
  end

  config.expect_with :rspec do |c|
    # TODO: we should maybe port existing tests to the new expect syntax
    c.syntax = [:should, :expect]
  end
end
