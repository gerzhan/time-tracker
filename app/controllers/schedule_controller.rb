require 'date'

class ScheduleController < ApplicationController

  def remaining_pto
    t = Date.today
    t = t - (t.month - 1).months
    t = t - (t.day - 1).days
    requests = TimeRequest.where("user_id = ? and \"to\" >= ? and time_request_type_id = ?", current_user.id, DateTime.now, TimeRequestType.find_by_name("PTO"))

    used_pto = 0
    requests.each { |request|
      if request.from.to_date == request.to.to_date
        if request.to - request.from > 8.hours
          used_pto += 8
        else
          used_pto += (request.to - request.from).hours
        end
      else
        (request.from.to_date..request.to.to_date).each { |d|
          if d.wday != 0 && d.wday != 6
            used_pto += 8
          end
        }
      end
    }
    current_user.yearly_pto_hour_allotment - used_pto
  end

  def index
    @remaining = remaining_pto
    @requests = TimeRequest.where("user_id = ? and \"to\" >= ?", current_user.id, DateTime.now).order(:from).page(params[:page])
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
      t.from = DateTime.strptime(params[:from], "%m/%d/%Y %H:%M")
    rescue
      t.from = Date.strptime(params[:from], "%m/%d/%Y")
    end
    begin
      t.to = DateTime.strptime(params[:to], "%m/%d/%Y %H:%M")
    rescue
      t.to = Date.strptime(params[:to], "%m/%d/%Y")
    end

    used_pto = 0
    if t.from.to_date == t.to.to_date
      if t.to - t.from > 8.hours
        used_pto += 8
      else
        used_pto += (t.to - t.from).hours
      end
    else
      (t.from.to_date..t.to.to_date).each { |d|
        if d.wday != 0 && d.wday != 6
          used_pto += 8
        end
      }
    end
    if remaining_pto - used_pto >= 0
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
    else
      flash[:error] = "Schedule Request Failed.  This request would cause your PTO remaining to drop below 0."
      redirect_to new_schedule_request_url
    end
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
    cur_from = t.from
    cur_to = t.to

    if t.user != current_user
      not_authorized
    end

    if DateTime.now < t.from
      prev_used = 0
      if t.from.to_date == t.to.to_date
        if t.to - t.from > 8.hours
          prev_used += 8
        else
          prev_used += (t.to - t.from).hours
        end
      else
        (t.from.to_date..t.to.to_date).each { |d|
          if d.wday != 0 && d.wday != 6
            prev_used += 8
          end
        }
      end

      t.user = current_user
      t.name = params[:name]
      t.comment = params[:comment]
      t.time_request_type = params[:time_request_type] != "" ? TimeRequestType.find(params[:time_request_type]) : nil
      begin
        t.from = DateTime.strptime(params[:from], "%m/%d/%Y %H:%M")
      rescue
        t.from = Date.strptime(params[:from], "%m/%d/%Y")
      end
      begin
        t.to = DateTime.strptime(params[:to], "%m/%d/%Y %H:%M")
      rescue
        t.to = Date.strptime(params[:to], "%m/%d/%Y")
      end

      now_used = 0
      if t.from.to_date == t.to.to_date
        if t.to - t.from > 8.hours
          now_used += 8
        else
          now_used += (t.to - t.from).hours
        end
      else
        (t.from.to_date..t.to.to_date).each { |d|
          if d.wday != 0 && d.wday != 6
            now_used += 8
          end
        }
      end

      diff = prev_used - now_used

      if remaining_pto - diff >= 0
        t.save!

        if t.from != cur_from || t.to != cur_to
          t.time_request_approval.each do |r|
            r.approved = false
            r.rejected = false
            r.save!
            UserMailer.reapprove_email(current_user, r.user, t, r).deliver
          end
        end

        flash[:success] = "Schedule Request Updated"
        redirect_to schedule_url(t.id)
      else 
        flash[:error] = "Schedule Request Update Failure.  This change would cause your remaining PTO to drop below 0."
        redirect_to schedule_url(t.id)
      end
    else 
      flash[:success] = "This Time Request has already past and cannot be updated."
      redirect_to schedule_url(t.id)
    end
  end

  def destroy
    t = TimeRequest.find(params[:id])

    if DateTime.now < t.from
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
    @remaining = current_user.yearly_pto_hour_allotment - remaining_pto
    @requests = TimeRequest.where("user_id = ? and \"to\"" < ?", current_user.id, DateTime.now).order(:from).page(params[:page])
  end

  def team
    if current_user.department.manager
      @users = User.where("department_id = ? or user_id = ?", current_user.department.id, current_user.department.manager).order(:username)
    else
      @users = User.where("department_id = ?", current_user.department.id).order(:username)
    end
    @base_date = (params[:week] ? Date.strptime(params[:week], "%m/%d/%Y") : Date.today)
    @base_date = @base_date - @base_date.wday.days
    end_date = @base_date + 7.days
    schedule_requests = TimeRequest.where("user_id in (?) and (\"from\" >= ? or \"to\" <= ?)", @users.collect { |x| x.id }, @base_date, end_date).keep_if { |x| !x.time_request_approval.collect { |y| y.approved }.include?(false) }

    @time = {}
    @users.each { |user|
      schedule = []
      (0..6).each { |day|
        schedule_i = ""
        first = true
        schedule_requests.each { |sh|
          if sh.user == user && sh.from.to_date <= @base_date + day.days && sh.to.to_date >= @base_date + day.days
            if !first
              schedule_i += "<br/><br/>"
            end
            schedule_i += "<u>Type: #{sh.time_request_type.name}</u><br/>Comment: #{sh.comment}<br/>When: #{sh.from.strftime("%H:%M")}-#{sh.to.strftime("%H:%M")}"
            first = false
          end
        }
        schedule << schedule_i
      }
      @time[user.username] = schedule
    }
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
