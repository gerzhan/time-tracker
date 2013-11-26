class ReportsController < ApplicationController

	def user_task_report
		if current_user.role != Role.MANAGER && current_user.role != Role.ADMIN
			not_authorized
		end

		@users = User.order(:username)
		if params[:user] && params[:user] != ""
			@selected_user = User.find(params[:user])
		else
			@selected_user = @users.first
		end

		@start = Date.today - Date.today.wday
	    @end = @start + 7.days

	    if !params[:start] || params[:start] == ""
	      params[:start] = @start.strftime("%m/%d/%Y")
	    end
	    if !params[:end] || params[:end] == ""
	      params[:end] = @end.strftime("%m/%d/%Y")
	    end

	    task_slots = TaskSlot.where("start_time >= ? and stop_time <= ? and task_id in (?)", @start, @end, Task.where(user: @selected_user).collect { |x| x.id })

	    @tasks = Task.where("id in (?)", task_slots.collect { |x| x.id })

	    @data = {}
	    task_slots.each { |task_slot|
	      if !@data["#{task_slot.task.task_project.name} #{task_slot.task.task_action.name} for #{task_slot.task.task_customer.name}"]
	        @data["#{task_slot.task.task_project.name} #{task_slot.task.task_action.name} for #{task_slot.task.task_customer.name}"] = 0
	      end

	      @data["#{task_slot.task.task_project.name} #{task_slot.task.task_action.name} for #{task_slot.task.task_customer.name}"] += ((task_slot.stop_time - task_slot.start_time) / 3600).round(2)
	    }

	    @tasks = @tasks.page(params[:page])
	end

	def department_task_report
		if current_user.role != Role.MANAGER && current_user.role != Role.ADMIN
			not_authorized
		end

		@departments = Department.order(:name)
		if params[:department] && params[:department] != ""
			@selected_department = Department.find(params[:department])
		else
			@selected_department = @departments.first
		end

		@start = Date.today - Date.today.wday
	    @end = @start + 7.days

	    if !params[:start] || params[:start] == ""
	      params[:start] = @start.strftime("%m/%d/%Y")
	    end
	    if !params[:end] || params[:end] == ""
	      params[:end] = @end.strftime("%m/%d/%Y")
	    end

	    task_slots = TaskSlot.where("start_time >= ? and stop_time <= ? and task_id in (?)", @start, @end, Task.where("user_id in (?)", User.where(department: @selected_department).collect { |y| y.id }).collect { |x| x.id })

	    @tasks = Task.where("id in (?)", task_slots.collect { |x| x.id })

	    @data = {}
	    task_slots.each { |task_slot|
	      if !@data["#{task_slot.task.task_project.name} #{task_slot.task.task_action.name} for #{task_slot.task.task_customer.name}"]
	        @data["#{task_slot.task.task_project.name} #{task_slot.task.task_action.name} for #{task_slot.task.task_customer.name}"] = 0
	      end

	      @data["#{task_slot.task.task_project.name} #{task_slot.task.task_action.name} for #{task_slot.task.task_customer.name}"] += ((task_slot.stop_time - task_slot.start_time) / 3600).round(2)
	    }

	    @tasks = @tasks.page(params[:page])
	end

	def user_schedule_report
		if current_user.role != Role.MANAGER && current_user.role != Role.ADMIN
			not_authorized
		end

		@users = User.order(:username)
		if params[:user] && params[:user] != ""
			@selected_user = User.find(params[:user])
		else
			@selected_user = @users.first
		end

	    @base_date = (params[:week] ? Date.strptime(params[:week], "%m/%d/%Y") : Date.today)
	    @base_date = @base_date - @base_date.wday.days
	    end_date = @base_date + 7.days
	    schedule_requests = TimeRequest.where("user_id = ? and (\"from\" >= ? or \"to\" <= ?)", @selected_user.id, @base_date, end_date).keep_if { |x| !x.time_request_approval.collect { |y| y.approved }.include?(false) }

	    @time = {}
	  	schedule = []
      	(0..6).each { |day|
        	schedule_i = ""
        	first = true
        	schedule_requests.each { |sh|
          		if sh.user == @selected_user && sh.from.to_date <= @base_date + day.days && sh.to.to_date >= @base_date + day.days
            		if !first
             			schedule_i += "<br/><br/>"
            		end
            		schedule_i += "<u>Type: #{sh.time_request_type.name}</u><br/>Comment: #{sh.comment}<br/>When: #{sh.from.strftime("%H:%M")}-#{sh.to.strftime("%H:%M")}"
            		first = false
          		end
        	}
        	schedule << schedule_i
      	}
      	@time[@selected_user.username] = schedule
	end

	def department_schedule_report
		if current_user.role != Role.MANAGER && current_user.role != Role.ADMIN
			not_authorized
		end

		@departments = Department.order(:name)
		if params[:department] && params[:department] != ""
			@selected_department = Department.find(params[:department])
		else
			@selected_department = @departments.first
		end

		if @selected_department.manager
	      @users = User.where("department_id = ? or user_id = ?", @selected_department.id, @selected_department.manager).order(:username)
	    else
	      @users = User.where("department_id = ?", @selected_department.id).order(:username)
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

end
