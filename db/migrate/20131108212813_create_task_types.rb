class CreateTaskTypes < ActiveRecord::Migration
  def change
    create_table :task_types do |t|
      t.string :name

      t.timestamps
    end

    t = TaskType.new
  	t.name = "Administrative Work"
  	t.save!

  	t = TaskType.new
  	t.name = "Productive Work"
  	t.save!

  end
end
