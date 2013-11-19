class TaskAction < ActiveRecord::Base

	has_many :task
	has_many :task_detail
	belongs_to :task_project
	
end
