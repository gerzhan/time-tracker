class ReportsController < ApplicationController

	def user_task_report
		if current_user.role != Role.MANAGER && current_user.role != Role.ADMIN
			not_authorized
		end

		@users = User.all
		if params[:user]

		end
	end

	def department_task_report
		if current_user.role != Role.MANAGER && current_user.role != Role.ADMIN
			not_authorized
		end

		@departments = Department.all
		if params[:department]

		end
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

        @users = [User.find(@selected_user.id)]
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
