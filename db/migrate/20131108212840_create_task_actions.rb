class CreateTaskActions < ActiveRecord::Migration
  def change
    create_table :task_actions do |t|
      t.string :name
      t.integer :task_project_id

      t.timestamps
    end

    TaskProject.all.each do |tp|
	    t = TaskAction.new
	    t.task_project = tp
		t.name = "Database"
		t.save!

		t = TaskAction.new
		t.task_project = tp
		t.name = "Design"
		t.save!

		t = TaskAction.new
		t.task_project = tp
		t.name = "Development"
		t.save!

		t = TaskAction.new
		t.task_project = tp
		t.name = "Integration"
		t.save!

		t = TaskAction.new
		t.task_project = tp
		t.name = "Meetings"
		t.save!

		t = TaskAction.new
		t.task_project = tp
		t.name = "Network"
		t.save!

		t = TaskAction.new
		t.task_project = tp
		t.name = "Reporting"
		t.save!

		t = TaskAction.new
		t.task_project = tp
		t.name = "Requirements"
		t.save!

		t = TaskAction.new
		t.task_project = tp
		t.name = "Research"
		t.save!

		t = TaskAction.new
		t.task_project = tp
		t.name = "Support"
		t.save!

		t = TaskAction.new
		t.task_project = tp
		t.name = "Testing"
		t.save!

		t = TaskAction.new
		t.task_project = tp
		t.name = "Training"
		t.save!
	end
  end
end
