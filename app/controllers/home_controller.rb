class HomeController < ApplicationController

	def index
		@tasks = Task.where("user_id = ? and task_status_id in (?)", current_user, [TaskStatus.STARTED, TaskStatus.RESUMED, TaskStatus.PAUSED, TaskStatus.SCHEDULED]).page(params[:page])
		@finished_tasks = Task.where("user_id = ? and task_status_id in (?)", current_user, [TaskStatus.COMPLETED]).order(:updated_at).page(params[:page])
	end

end
