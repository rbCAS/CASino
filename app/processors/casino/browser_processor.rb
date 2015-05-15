module CASino::BrowserProcessor
  extend ActiveSupport::Concern

  def browser_info(user_agent)
    user_agent = UserAgent.parse(user_agent)
    "#{user_agent.browser} (#{user_agent.platform})"
  end

  def same_browser?(user_agent, other_user_agent)
    user_agent == other_user_agent || browser_info(user_agent) == browser_info(other_user_agent)
  end
end
