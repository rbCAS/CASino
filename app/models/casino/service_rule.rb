
class CASino::ServiceRule < ActiveRecord::Base
  validates :name, presence: true
  validates :url, uniqueness: true, presence: true

  def self.allowed?(service_url)
    rules = self.where(enabled: true)
    if rules.empty? && !CASino.config.require_service_rules
      true
    else
      rules.any? { |rule| rule.allows?(service_url) }
    end
  end

  def allows?(service_url)
    if self.regex?
      regex = Regexp.new self.url, true
      if regex =~ service_url
        return true
      end
    elsif self.url == service_url
      return true
    end
    false
  end
end
