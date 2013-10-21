require_relative 'listener'

class CASino::LogoutListener < CASino::Listener
  def user_logged_out(url, redirect_immediately = false)
    if redirect_immediately
      @controller.redirect_to url, status: :see_other
    else
      assign(:url, url)
    end
    @controller.cookies.delete :tgt
  end
end
