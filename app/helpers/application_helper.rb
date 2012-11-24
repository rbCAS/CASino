module ApplicationHelper
  def random_ticket_string(prefix, length = 40)
    random_string = rand(36**length).to_s(36)
    "#{prefix}-#{Time.now.to_i}-#{random_string}"
  end

  def browser_info(user_agent)
    user_agent = UserAgent.parse(user_agent)
    "#{user_agent.browser} (#{user_agent.platform})"
  end

  def same_browser?(user_agent, other_user_agent)
    user_agent == other_user_agent || browser_info(user_agent) == browser_info(other_user_agent)
  end
end
