class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :require_login

  def not_authenticated
  	flash[:error] = "You must be logged to view this page."
    redirect_to login_path
  end

  def not_authorized
  	redirect_to root_url, :alert => "You are not authorized to access this page."
  end

  rescue_from CanCan::AccessDenied do |exception|
    not_authorized
  end

end
