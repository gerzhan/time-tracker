class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :require_login

  def not_authenticated
  	flash[:error] = "You must be logged to view this page."
    redirect_to login_path
  end

end
