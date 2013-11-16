class CreateTaskDetails < ActiveRecord::Migration
  def change
    create_table :task_details do |t|
      t.string :name

      t.timestamps
    end

    t = TaskDetail.new
	t.name = "Functional"
	t.save!

	t = TaskDetail.new
	t.name = "Integration"
	t.save!

	t = TaskDetail.new
	t.name = "Stress"
	t.save!

	t = TaskDetail.new
	t.name = "User"
	t.save!

  end
end
