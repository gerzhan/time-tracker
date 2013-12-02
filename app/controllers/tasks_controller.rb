class TasksController < ApplicationController
  include CalendarInviteSender
  
  def index
      @tasks = Task.where("user_id = ? and task_status_id in (?)", current_user, [TaskStatus.STARTED, TaskStatus.RESUMED, TaskStatus.PAUSED, TaskStatus.SCHEDULED]).page(params[:page])
  end

  def scheduled_new
      @types = TaskType.order(:name)
      @customers = TaskCustomer.order(:name)
      @projects = TaskProject.order(:name)
      @actions = TaskAction.order(:name)
      @details = TaskDetail.order(:name)
  end

  def new
      @types = TaskType.order(:name)
      @customers = TaskCustomer.order(:name)
      @projects = TaskProject.order(:name)
      @actions = TaskAction.order(:name)
      @details = TaskDetail.order(:name)
  end

  def scheduled_create
    t = Task.new
    t.name = params[:name]
    t.comment = params[:comment]
    t.scheduled_for = DateTime.strptime(params[:scheduled_for], "%m/%d/%Y %H:%M")
    t.task_type = (params[:task_type] != "" ? TaskType.find(params[:task_type]) : nil)
    t.task_customer = (params[:task_customer] != "" ? TaskCustomer.find(params[:task_customer]) : nil)
    t.task_project = (params[:task_project] != "" ? TaskProject.find(params[:task_project]) : nil)
    t.task_action = (params[:task_action] != "" ? TaskAction.find(params[:task_action]) : nil)
    t.task_detail = (params[:task_detail] != "" ? TaskDetail.find(params[:task_detail]) : nil)
    t.user = current_user
    t.task_status = TaskStatus.SCHEDULED
    t.save!

    create_calendar_event(t, current_user)
    send_scheduled_task_item(current_user, t)

    flash[:success] = "Scheduled New Task"
    redirect_to tasks_url
  end

  def create
    t = Task.new
    t.name = params[:name]
    t.comment = params[:comment]
    t.scheduled_for = DateTime.now
    t.task_type = (params[:task_type] != "" ? TaskType.find(params[:task_type]) : nil)
    t.task_customer = (params[:task_customer] != "" ? TaskCustomer.find(params[:task_customer]) : nil)
    t.task_project = (params[:task_project] != "" ? TaskProject.find(params[:task_project]) : nil)
    t.task_action = (params[:task_action] != "" ? TaskAction.find(params[:task_action]) : nil)
    t.task_detail = (params[:task_detail] != "" ? TaskDetail.find(params[:task_detail]) : nil)
    t.user = current_user
    t.task_status = TaskStatus.STARTED
    t.save!

    ts = TaskSlot.new
    ts.task = t
    ts.start_time = Time.now
    ts.save!

    flash[:success] = "Started New Task"
    redirect_to tasks_url
  end

  def scheduled_show
    @task = Task.find(params[:id])

    if @task.user != current_user
      not_authorized
    end
  end

  def show
    @task = Task.find(params[:id])

    if @task.user != current_user
      not_authorized
    end
  end

  def scheduled_edit
    @task = Task.find(params[:id])

    if @task.user != current_user
      not_authorized
    end

    @types = TaskType.order(:name)
    @customers = TaskCustomer.order(:name)
    @projects = TaskProject.order(:name)
    @actions = TaskAction.order(:name)
    @details = TaskDetail.order(:name)
  end

  def edit
    @task = Task.find(params[:id])

    if @task.user != current_user
      not_authorized
    end

    @types = TaskType.order(:name)
    @customers = TaskCustomer.order(:name)
    @projects = TaskProject.order(:name)
    @actions = TaskAction.order(:name)
    @details = TaskDetail.order(:name)
  end

  def scheduled_update
    t = Task.find(params[:id])

    if t.user != current_user
      not_authorized
    end

    t.name = params[:name]
    t.comment = params[:comment]
    t.scheduled_for = DateTime.strptime(params[:scheduled_for], "%m/%d/%Y %H:%M")
    t.task_type = (params[:task_type] != "" ? TaskType.find(params[:task_type]) : nil)
    t.task_customer = (params[:task_customer] != "" ? TaskCustomer.find(params[:task_customer]) : nil)
    t.task_project = (params[:task_project] != "" ? TaskProject.find(params[:task_project]) : nil)
    t.task_action = (params[:task_action] != "" ? TaskAction.find(params[:task_action]) : nil)
    t.task_detail = (params[:task_detail] != "" ? TaskDetail.find(params[:task_detail]) : nil)
    t.user = current_user
    t.task_status = TaskStatus.STARTED
    t.save!

    create_calendar_event(t, current_user)
    send_scheduled_task_item(current_user, t)

    flash[:success] = "Task Updated"
    redirect_to task_url(t.id)
  end

  def update
    t = Task.find(params[:id])

    if t.user != current_user
      not_authorized
    end

    t.name = params[:name]
    t.comment = params[:comment]
    t.task_type = (params[:task_type] != "" ? TaskType.find(params[:task_type]) : nil)
    t.task_customer = (params[:task_customer] != "" ? TaskCustomer.find(params[:task_customer]) : nil)
    t.task_project = (params[:task_project] != "" ? TaskProject.find(params[:task_project]) : nil)
    t.task_action = (params[:task_action] != "" ? TaskAction.find(params[:task_action]) : nil)
    t.task_detail = (params[:task_detail] != "" ? TaskDetail.find(params[:task_detail]) : nil)
    t.user = current_user
    t.task_status = TaskStatus.STARTED
    t.save!

    flash[:success] = "Task Updated"
    redirect_to task_url(t.id)
  end

  def scheduled_destroy
    t = Task.find(params[:id])

    if t.user != current_user
      not_authorized
    end

    cancel_calendar_event(t, current_user)
    send_scheduled_task_item(current_user, t)

    t.delete

    flash[:success] = "Scheduled Task Deleted"
    redirect_to tasks_url
  end

  def duplicate
    to = Task.find(params[:id])

    if to.user != current_user && to.task_status != TaskStatus.COMPLETED
      not_authorized
    end

    t = Task.new
    t.name = to.name
    t.comment = to.comment
    t.scheduled_for = DateTime.now
    t.task_type = to.task_type
    t.task_customer = to.task_customer
    t.task_project = to.task_project
    t.task_action = to.task_action
    t.task_detail = to.task_detail
    t.user = current_user
    t.task_status = TaskStatus.STARTED
    t.save!

    ts = TaskSlot.new
    ts.task = t
    ts.start_time = Time.now
    ts.save!

    flash[:success] = "Duplicted Task"
    redirect_to tasks_url
  end

  def pause
    t = Task.find(params[:id])

    if t.user != current_user
      not_authorized
    end

    t.task_status = TaskStatus.PAUSED
    t.save!

    ts = t.task_slot.last
    ts.stop_time = Time.now
    ts.save!

    flash[:notice] = "Task Started"
    redirect_to :back
  end

  def resume
    t = Task.find(params[:id])

    if t.user != current_user
      not_authorized
    end

    t.task_status = TaskStatus.RESUMED
    t.save!

    ts = TaskSlot.new
    ts.task = t
    ts.start_time = Time.now
    ts.save!

    flash[:notice] = "Task Resumed"
    redirect_to :back
  end

  def stop
    t = Task.find(params[:id])

    if t.user != current_user
      not_authorized
    end
    
    t.task_status = TaskStatus.COMPLETED
    t.save!

    ts = t.task_slot.last
    if ts.stop_time == nil
      ts.stop_time = Time.now
    end
    ts.save!

    flash[:notice] = "Task Completed"
    redirect_to tasks_url
  end

  def history
    @start = Date.today - Date.today.wday
    @end = @start + 7.days

    if !params[:start] || params[:start] == ""
      params[:start] = @start.strftime("%m/%d/%Y")
    end
    if !params[:end] || params[:end] == ""
      params[:end] = @end.strftime("%m/%d/%Y")
    end

    @tasks = Task.where("user_id = ? and task_status_id = ? and created_at >= ? and updated_at <= ?", current_user, TaskStatus.COMPLETED, Date.strptime(params[:start], "%m/%d/%Y"), Date.strptime(params[:end], "%m/%d/%Y"))

    @data = {}
    @tasks.each { |task|
      if !@data["#{task.task_project.name} #{task.task_action.name} for #{task.task_customer.name}"]
        @data["#{task.task_project.name} #{task.task_action.name} for #{task.task_customer.name}"] = 0
      end

      sum = 0.0
      task.task_slot.each { |ts|
        sum += ((ts.stop_time - ts.start_time) / 3600).round(2)
      }

      @data["#{task.task_project.name} #{task.task_action.name} for #{task.task_customer.name}"] += sum
    }

    @tasks = @tasks.page(params[:page])
  end

  def create_calendar_event(task, creator) 
    File.open("#{Rails.root}/public/schedule_tasks/#{task.id}.ics", "w") do |file|
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
      file.write "DESCRIPTION;LANGUAGE=en-US:#{task.comment}\n"
      file.write "SUMMARY;LANGUAGE=en-US: Scheduled Task - #{task.name}\n"
      file.write "DTSTART;TZID=Eastern Standard Time:#{task.scheduled_for.strftime("%Y%m%dT%H%M%S")}\n"
      file.write "DTEND;TZID=Eastern Standard Time:#{(task.scheduled_for + 1.hours).strftime("%Y%m%dT%H%M%S")}\n"
      file.write "UID: time-tracker-scheduled-task-#{task.id}-#{creator.email}\n"
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
      file.write "BEGIN:VALARM\n"
      file.write "TRIGGER:-P1D\n"
      file.write "ACTION:EMAIL\n"
      file.write "ATTENDEE:MAILTO: #{creator.email}\n"
      file.write "SUMMARY:*** REMINDER: Scheduled Task - #{task.name} ***\n"
      file.write "DESCRIPTION: Your task is scheduled to begin tomorrow.\n"
      file.write "END:VALARM\n"
      file.write "BEGIN:VALARM\n"
      file.write "TRIGGER:-P1H\n"
      file.write "ACTION:EMAIL\n"
      file.write "ATTENDEE:MAILTO: #{creator.email}\n"
      file.write "SUMMARY:*** REMINDER: Scheduled Task - #{task.name} ***\n"
      file.write "DESCRIPTION: Your task is scheduled to begin in 1 hour.\n"
      file.write "END:VALARM\n"
      file.write "END:VCALENDAR\n"
    end
  end

  def cancel_calendar_event(task, creator)
    File.open("#{Rails.root}/public/scheduled_tasks/#{task.id}.ics", "w") do |file|
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
      file.write "DESCRIPTION;LANGUAGE=en-US:#{task.comment}\n"
      file.write "SUMMARY;LANGUAGE=en-US: Scheduled Task - #{task.name}\n"
      file.write "DTSTART;TZID=Eastern Standard Time:#{task.scheduled_for.strftime("%Y%m%dT%H%M%S")}\n"
      file.write "DTEND;TZID=Eastern Standard Time:#{(task.scheduled_for + 1.hours).strftime("%Y%m%dT%H%M%S")}\n"
      file.write "UID: time-tracker-scheduled-task-#{task.id}-#{creator.email}\n"
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
      file.write "BEGIN:VALARM\n"
      file.write "TRIGGER:-P1D\n"
      file.write "ACTION:EMAIL\n"
      file.write "ATTENDEE:MAILTO: #{creator.email}\n"
      file.write "SUMMARY:*** REMINDER: Scheduled Task - #{task.name} ***\n"
      file.write "DESCRIPTION: Your task is scheduled to begin tomorrow.\n"
      file.write "END:VALARM\n"
      file.write "BEGIN:VALARM\n"
      file.write "TRIGGER:-P1H\n"
      file.write "ACTION:EMAIL\n"
      file.write "ATTENDEE:MAILTO: #{creator.email}\n"
      file.write "SUMMARY:*** REMINDER: Scheduled Task - #{task.name} ***\n"
      file.write "DESCRIPTION: Your task is scheduled to begin in 1 hour.\n"
      file.write "END:VALARM\n"
      file.write "END:VCALENDAR\n"
    end
  end
end
