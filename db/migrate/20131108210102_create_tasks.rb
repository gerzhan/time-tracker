class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :name
      
      t.integer :user_id
      t.integer :task_type_id
      t.integer :task_customer_id
      t.integer :task_project_id
      t.integer :task_action_id
      t.integer :task_detail_id
      t.integer :task_status_id

      t.string :comment
      t.timestamp :scheduled_for

      t.timestamps
    end
  end
end
