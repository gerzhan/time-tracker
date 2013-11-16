class Task < ActiveRecord::Base

	belongs_to :task_status
	belongs_to :task_type
	belongs_to :task_customer
	belongs_to :task_project
	belongs_to :task_detail
	belongs_to :task_action
	belongs_to :user
	has_many :task_slot

end
