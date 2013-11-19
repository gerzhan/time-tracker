class TaskDetail < ActiveRecord::Base

	has_many :task
	belongs_to :task_action
	
end
