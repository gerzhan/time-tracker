require 'date'

namespace :tasks do
  desc "TODO"
  task auto_pause: :environment do
  	Task.where("task_status_id in (?)", [TaskStatus.STARTED.id, TaskStatus.RESUMED.id]).each do |task|
  		task.task_status = TaskStatus.PAUSED
  		task.save!
  	end
  end

  task auto_start: :environment do
  	Task.where("task_status_id = ? and scheduled_for <= ?", TaskStatus.SCHEDULED.id, DateTime.now).each do |task|
  		task.task_status = TaskStatus.STARTED
  		task.save!

  		ts = TaskSlot.new
	    ts.task = task
	    ts.start_time = Time.now
	    ts.save!
  	end
  end

end
