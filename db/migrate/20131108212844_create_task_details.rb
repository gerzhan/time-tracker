class CreateTaskDetails < ActiveRecord::Migration
  def change
    create_table :task_details do |t|
      t.string :name
      t.integer :task_action_id

      t.timestamps
    end

    TaskAction.where(name: "Testing").each do |ta|
	    t = TaskDetail.new
	    t.task_action = ta
		t.name = "Functional"
		t.save!

		t = TaskDetail.new
		t.task_action = ta
		t.name = "Integration"
		t.save!

		t = TaskDetail.new
		t.task_action = ta
		t.name = "Stress"
		t.save!

		t = TaskDetail.new
		t.task_action = ta
		t.name = "User"
		t.save!
	end
  end
end
