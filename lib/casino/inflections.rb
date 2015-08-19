# This inflector acronym definition needs to happen as soon as possible because
# the Railtie is going to declare a table_name_suffix based upon the name of the
# Railtie. Without this definition, the Railtie would use 'ca_s_ino'
ActiveSupport::Inflector.inflections do |inflect|
  inflect.acronym 'CASino'
end