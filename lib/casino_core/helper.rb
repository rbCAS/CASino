module CASinoCore
  module Helper
    def random_ticket_string(prefix, length = 40)
      random_string = rand(36**length).to_s(36)
      "#{prefix}-#{Time.now.to_i}-#{random_string}"
    end
  end
end
