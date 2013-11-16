class CreateTaskActions < ActiveRecord::Migration
  def change
    create_table :task_actions do |t|
      t.string :name

      t.timestamps
    end

    t = TaskAction.new
	t.name = "Database"
	t.save!

	t = TaskAction.new
	t.name = "Design"
	t.save!

	t = TaskAction.new
	t.name = "Development"
	t.save!

	t = TaskAction.new
	t.name = "Integration"
	t.save!

	t = TaskAction.new
	t.name = "Meetings"
	t.save!

	t = TaskAction.new
	t.name = "Network"
	t.save!

	t = TaskAction.new
	t.name = "Reporting"
	t.save!

	t = TaskAction.new
	t.name = "Requirements"
	t.save!

	t = TaskAction.new
	t.name = "Research"
	t.save!

	t = TaskAction.new
	t.name = "Support"
	t.save!

	t = TaskAction.new
	t.name = "Testing"
	t.save!

	t = TaskAction.new
	t.name = "Training"
	t.save!

  end
end
