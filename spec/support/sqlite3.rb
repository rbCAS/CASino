root_path   = File.join(File.dirname(__FILE__), '..')
schema_path = File.join(root_path, 'dummy', 'db')

load File.join(schema_path, 'schema.rb')
