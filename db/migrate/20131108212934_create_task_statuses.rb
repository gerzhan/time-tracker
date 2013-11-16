class CreateTaskStatuses < ActiveRecord::Migration
  def change
    create_table :task_statuses do |t|
      t.string :name

      t.timestamps
    end

    t = TaskStatus.new
    t.name = "STARTED"
    t.save!

	t = TaskStatus.new
    t.name = "RESUMED"
    t.save!

    t = TaskStatus.new
    t.name = "PAUSED"
    t.save!

    t = TaskStatus.new
    t.name = "COMPLETED"
    t.save!    
  end
end
