class SessionsController < ApplicationController

  def new
    redirect_to videos_path if logged_in?
  end

  def create
    user = User.where(email: params[:email]).first
    if user and user.authenticate(params["password"])
      session["user_id"] = user.id
      redirect_to videos_path, notice: "You are signed in." 
    else 
      flash["error"] = "There was a problem with either your email address or password"
      redirect_to sign_in_path
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "You are logged out."
  end
end