require 'date'
require 'pony'

class ScheduleController < ApplicationController
  include CalendarInviteSender

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

      cancel_calednar_event(t, t.user, t.time_request_approval.collect { |a| a.user })

      send_calendar_item(current_user, t)

      t.time_request_approval.each do |r|
        UserMailer.retracted_email(current_user, r.user, t).deliver
        send_calendar_item(r.user, t)
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
      create_calendar_event(t.time_request, t.time_request.user, t.time_request.time_request_approval.collect { |a| a.user })

      UserMailer.approved_email(t.time_request.user, t.time_request).deliver
      send_calendar_item(t.time_request.user, t.time_request)

      t.time_request.time_request_approval.each do |approval|
        UserMailer.approved_email(approval.user, t.time_request).deliver
        send_calendar_item(approval.user, t.time_request)
      end
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

  def create_calendar_event(event, creator, approvers) 
    File.open("#{Rails.root}/public/schedule_requests/#{event.id}.ics", "w") do |file|
      file.write "BEGIN:VCALENDAR\n"
      file.write "METHOD:REQUEST\n"
      file.write "PRODID:Microsoft Exchange Server 2010\n"
      file.write "VERSION:2.0\n"
      file.write "BEGIN:VTIMEZONE\n"
      file.write "TZID:Eastern Standard Time\n"
      file.write "BEGIN:STANDARD\n"
      file.write "DTSTART:16010101T020000\n"
      file.write "TZOFFSETFROM:-0400\n"
      file.write "TZOFFSETTO:-0500\n"
      file.write "RRULE:FREQ=YEARLY;INTERVAL=1;BYDAY=1SU;BYMONTH=11\n"
      file.write "END:STANDARD\n"
      file.write "BEGIN:DAYLIGHT\n"
      file.write "DTSTART:16010101T020000\n"
      file.write "TZOFFSETFROM:-0500\n"
      file.write "TZOFFSETTO:-0400\n"
      file.write "RRULE:FREQ=YEARLY;INTERVAL=1;BYDAY=2SU;BYMONTH=3\n"
      file.write "END:DAYLIGHT\n"
      file.write "END:VTIMEZONE\n"
      file.write "BEGIN:VEVENT\n"
      file.write "ORGANIZER;CN=#{creator.first_name} #{creator.last_name}:MAILTO:#{creator.email}\n"
      approvers.each do |approver|
        file.write "ATTENDEE;ROLE=REQ-PARTICIPANT;PARTSTAT=ACCEPTED;RSVP=TRUE;CN=#{approver.first_name} #{approver.last_name}:MAILTO:#{approver.email}\n"
      end
      file.write "DESCRIPTION;LANGUAGE=en-US:#{event.comment}\n"
      file.write "SUMMARY;LANGUAGE=en-US:#{event.time_request_type ? event.time_request_type.name : "Event"} #{event.name}\n"
      file.write "DTSTART;TZID=Eastern Standard Time:#{event.from.strftime("%Y%m%dT%H%M%S")}\n"
      file.write "DTEND;TZID=Eastern Standard Time:#{event.to.strftime("%Y%m%dT%H%M%S")}\n"
      file.write "UID: time-tracker-generated-event-#{event.id}-#{creator.email}\n"
      file.write "CLASS:PUBLIC\n"
      file.write "PRIORITY:5\n"
      file.write "DTSTAMP:#{DateTime.now.strftime("%Y%m%dT%H%M%SZ")}\n"
      file.write "TRANSP:OPAQUE\n"
      file.write "STATUS:CONFIRMED\n"
      file.write "SEQUENCE:0\n"
      file.write "LOCATION;LANGUAGE=en-US:\n"
      file.write "X-MICROSOFT-CDO-APPT-SEQUENCE:0\n"
      file.write "X-MICROSOFT-CDO-OWNERAPPTID:-1531201571\n"
      file.write "X-MICROSOFT-CDO-BUSYSTATUS:TENTATIVE\n"
      file.write "X-MICROSOFT-CDO-INTENDEDSTATUS:FREE\n"
      file.write "X-MICROSOFT-CDO-ALLDAYEVENT:FALSE\n"
      file.write "X-MICROSOFT-CDO-IMPORTANCE:1\n"
      file.write "X-MICROSOFT-CDO-INSTTYPE:0\n"
      file.write "X-MICROSOFT-DISALLOW-COUNTER:FALSE\n"
      file.write "END:VEVENT\n"
      file.write "END:VCALENDAR\n"
    end
  end

  def cancel_calednar_event(event, creator, approvers)
    File.open("#{Rails.root}/public/schedule_requests/#{event.id}.ics", "w") do |file|
      file.write "BEGIN:VCALENDAR\n"
      file.write "METHOD:CANCEL\n"
      file.write "PRODID:Microsoft Exchange Server 2010\n"
      file.write "VERSION:2.0\n"
      file.write "BEGIN:VTIMEZONE\n"
      file.write "TZID:Eastern Standard Time\n"
      file.write "BEGIN:STANDARD\n"
      file.write "DTSTART:16010101T020000\n"
      file.write "TZOFFSETFROM:-0400\n"
      file.write "TZOFFSETTO:-0500\n"
      file.write "RRULE:FREQ=YEARLY;INTERVAL=1;BYDAY=1SU;BYMONTH=11\n"
      file.write "END:STANDARD\n"
      file.write "BEGIN:DAYLIGHT\n"
      file.write "DTSTART:16010101T020000\n"
      file.write "TZOFFSETFROM:-0500\n"
      file.write "TZOFFSETTO:-0400\n"
      file.write "RRULE:FREQ=YEARLY;INTERVAL=1;BYDAY=2SU;BYMONTH=3\n"
      file.write "END:DAYLIGHT\n"
      file.write "END:VTIMEZONE\n"
      file.write "BEGIN:VEVENT\n"
      file.write "ORGANIZER;CN=#{creator.first_name} #{creator.last_name}:MAILTO:#{creator.email}\n"
      approvers.each do |approver|
        file.write "ATTENDEE;ROLE=REQ-PARTICIPANT;PARTSTAT=ACCEPTED;RSVP=TRUE;CN=#{approver.first_name} #{approver.last_name}:MAILTO:#{approver.email}\n"
      end
      file.write "DESCRIPTION;LANGUAGE=en-US:#{event.comment}\n"
      file.write "SUMMARY;LANGUAGE=en-US:#{event.time_request_type ? event.time_request_type.name : "Event"} #{event.name}\n"
      file.write "DTSTART;TZID=Eastern Standard Time:#{event.from.strftime("%Y%m%dT%H%M%S")}\n"
      file.write "DTEND;TZID=Eastern Standard Time:#{event.to.strftime("%Y%m%dT%H%M%S")}\n"
      file.write "UID: time-tracker-generated-event-#{event.id}-#{creator.email}\n"
      file.write "CLASS:PUBLIC\n"
      file.write "PRIORITY:5\n"
      file.write "DTSTAMP:#{DateTime.now.strftime("%Y%m%dT%H%M%SZ")}\n"
      file.write "TRANSP:OPAQUE\n"
      file.write "STATUS:CANCELLED\n"
      file.write "SEQUENCE:0\n"
      file.write "LOCATION;LANGUAGE=en-US:\n"
      file.write "X-MICROSOFT-CDO-APPT-SEQUENCE:0\n"
      file.write "X-MICROSOFT-CDO-OWNERAPPTID:-1531201571\n"
      file.write "X-MICROSOFT-CDO-BUSYSTATUS:TENTATIVE\n"
      file.write "X-MICROSOFT-CDO-INTENDEDSTATUS:FREE\n"
      file.write "X-MICROSOFT-CDO-ALLDAYEVENT:FALSE\n"
      file.write "X-MICROSOFT-CDO-IMPORTANCE:1\n"
      file.write "X-MICROSOFT-CDO-INSTTYPE:0\n"
      file.write "X-MICROSOFT-DISALLOW-COUNTER:FALSE\n"
      file.write "END:VEVENT\n"
      file.write "END:VCALENDAR\n"
    end
  end
end
