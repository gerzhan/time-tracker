class TaskStatus < ActiveRecord::Base

	has_many :task

	def self.STARTED
		TaskStatus.find_by_name("STARTED")
	end

	def self.RESUMED
		TaskStatus.find_by_name("RESUMED")
	end

	def self.PAUSED
		TaskStatus.find_by_name("PAUSED")
	end

	def self.COMPLETED
		TaskStatus.find_by_name("COMPLETED")
	end

end
