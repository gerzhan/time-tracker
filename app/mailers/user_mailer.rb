class UserMailer < ActionMailer::Base
  default from: "system@timetracker.io"

  def welcome_email(user)
    @user = user
    @url = root_url
    mail(:to => user.email, :subject => "Login Created")
  end

  def reset_password_email(user)
    @user = user
    @url  = change_password_url(user.reset_password_token)
    mail(:to => user.email, :subject => "Password Reset Request")
  end

  def approve_email(requesting_user, approving_user, time_request, time_request_approval)
    @requesting_user = requesting_user
    @approving_user = approving_user
    @time_request = time_request
    @approve_link = approve_schedule_url(time_request_approval)
    @reject_link = reject_schedule_url(time_request_approval)
    mail(:to => approving_user.email, :subject => "#{time_request.time_request_type ? time_request.time_request_type.name : ""} Schedule Request")
  end

  def reapprove_email(requesting_user, approving_user, time_request, time_request_approval)
    @requesting_user = requesting_user
    @approving_user = approving_user
    @time_request = time_request
    @approve_link = approve_schedule_url(time_request_approval)
    @reject_link = reject_schedule_url(time_request_approval)
    mail(:to => approving_user.email, :subject => "#{time_request.time_request_type ? time_request.time_request_type.name : ""} Schedule Request Update")
  end

  def retracted_email(retracting_user, approving_user, time_request)
    @retracting_user = retracting_user
    @approving_user = approving_user
    @time_request = time_request
    mail(:to => approving_user.email, :subject => "#{time_request.time_request_type ? time_request.time_request_type.name : ""} Schedule Request Retracted")
  end

  def approved_email(user, time_request)
    @user = user
    @time_request = time_request
    mail(:to => user.email, :subject => "#{time_request.name} Approved")
  end

  def rejected_email(user, rejecting_user, time_request, reason)
    @user = user
    @rejecting_user = rejecting_user
    @time_request = time_request
    @reason = reason
    mail(:to => user.email, :subject => "#{time_request.name} Rejected by #{rejecting_user.username}")
  end
end
