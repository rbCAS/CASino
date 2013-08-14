require 'casino_core/model'

class CASinoCore::Model::ValidationResult < Struct.new(:error_code, :error_message, :error_severity)
  def success?
    self.error_code.nil?
  end
end
