require 'date'

class ScheduleController < ApplicationController

  def index
    @requests = TimeRequest.where("user_id = ? and \"to\" >= ?", current_user.id, DateTime.now).order(:from)
  end

  def new
    @time_request_types = TimeRequestType.order(:name)
  end

  def create
    t = TimeRequest.new
    t.user = current_user
    t.name = params[:name]
    t.comment = params[:comment]
    t.time_request_type = params[:time_request_type] != "" ? TimeRequestType.find(params[:time_request_type]) : nil
    begin
      t.from = Date.strptime(params[:from], "%m/%d/%Y %H:%M")
    rescue
      t.from = Date.strptime(params[:from], "%m/%d/%Y")
    end
    begin
      t.to = Date.strptime(params[:to], "%m/%d/%Y %H:%M")
    rescue
      t.to = Date.strptime(params[:to], "%m/%d/%Y")
    end
    t.save!

    TimeRequestApprover.where(department: current_user.department, time_request_type: t.time_request_type).each do |approver|
      r = TimeRequestApproval.new
      r.time_request = t;
      r.user = approver.user
      r.approved = false
      r.rejected = false
      r.save!
      UserMailer.approve_email(current_user, approver.user, t, r).deliver
    end

    flash[:success] = "Schedule Request Created"
    redirect_to schedule_index_url
  end

  def show
    @time_request = TimeRequest.find(params[:id])

    if @time_request.user != current_user
      not_authorized
    end
  end

  def edit
    @time_request = TimeRequest.find(params[:id])
    @time_request_types = TimeRequestType.order(:name)

    if @time_request.user != current_user
      not_authorized
    end
  end

  def update
    t = TimeRequest.find(params[:id])

    if t.user != current_user
      not_authorized
    end

    if DateTime.now > t.from
      t.user = current_user
      t.name = params[:name]
      t.comment = params[:comment]
      t.time_request_type = params[:time_request_type] != "" ? TimeRequestType.find(params[:time_request_type]) : nil
      begin
        t.from = Date.strptime(params[:from], "%m/%d/%Y %H:%M")
      rescue
        t.from = Date.strptime(params[:from], "%m/%d/%Y")
      end
      begin
        t.to = Date.strptime(params[:to], "%m/%d/%Y %H:%M")
      rescue
        t.to = Date.strptime(params[:to], "%m/%d/%Y")
      end
      t.save!

      t.time_request_approval.each do |r|
        r.approved = false
        r.rejected = false
        r.save!
        UserMailer.reapprove_email(current_user, r.user, t, r).deliver
      end

      flash[:success] = "Schedule Request Updated"
      redirect_to schedule_url(t.id)
    else 
      flash[:success] = "This Time Request has already past and cannot be updated."
      redirect_to schedule_url(t.id)
    end
  end

  def destroy
    t = TimeRequest.find(params[:id])

    if DateTime.now > t.from
      if t.user != current_user
        not_authorized
      end

      t.time_request_approval.each do |r|
        UserMailer.retracted_email(current_user, r.user, t).deliver
        r.delete
      end

      t.delete

      flash[:success] = "Schedule Request Deleted"
      redirect_to schedule_index_url
    else 
      flash[:success] = "This Time Request has already past and cannot be deleted."
      redirect_to schedule_url(t.id)
    end
  end

  def history
    @requests = TimeRequest.where("user_id = ? and \"to\"" < ?", current_user.id, DateTime.now).order(:from)
  end

  def team
    
  end

  def approve
    t = TimeRequestApproval.find(params[:id])

    if current_user != t.user
      not_authorized
    end

    t.approved = true
    t.rejected = false
    t.save!

    if !t.time_request.time_request_approval.collect { |x| x.approved }.include?(false)
      UserMailer.approved_email(t.time_request.user, t.time_request).deliver
    end
  end

  def reject
    @time_request_approval = TimeRequestApproval.find(params[:id])

    if current_user != @time_request_approval.user
      not_authorized
    end
  end

  def confirm_reject
    t = TimeRequestApproval.find(params[:id])

    if current_user != t.user
      not_authorized
    end

    t.rejected = true
    t.approved = false
    t.reject_reason = params[:reason]
    t.save!
    
    UserMailer.rejected_email(t.time_request.user, t.user, t.time_request, params[:reason]).deliver

    render "approve"
  end

end
