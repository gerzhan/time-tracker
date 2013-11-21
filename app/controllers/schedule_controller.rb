require 'date'

class ScheduleController < ApplicationController
  
  def index
    @requests = TimeRequest.where("user_id = ? and to >= ?", current_user.id, Date.now).order(:from)
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
    end

    flash[:success] = "Schedule Request Updated"
    redirect_to schedule_url(t.id)
  end

  def destroy
    t = TimeRequest.find(params[:id])

    if Date.now < t.from
      if t.user != current_user
        not_authorized
      end

      t.time_request_approval.each do |r|
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
    @requests = TimeRequest.where("user_id = ? and to < ?", current_user.id, Date.now).order(:from)
  end

  def team
    
  end

  def approve

  end

  def reject

  end

  def confirm_reject

  end

end
