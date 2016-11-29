class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method  :current_user, :logged_in?, :require_user

  def current_user 
    @current_user ||= User.find(session["user_id"]) if session['user_id']
  end

  def logged_in?
    !!current_user
  end

  def require_user
    unless logged_in?
      flash[:error] = 'You must be logged in to perform that action.'
      redirect_to sign_in_path unless logged_in?
    end
  end
end