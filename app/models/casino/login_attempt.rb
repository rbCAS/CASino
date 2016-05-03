class CASino::LoginAttempt < ActiveRecord::Base
  include CASino::ModelConcern::BrowserInfo

  belongs_to :user

  def username=(username)
    super

    self.user = CASino::User.find_by_username(username)
  end
end
