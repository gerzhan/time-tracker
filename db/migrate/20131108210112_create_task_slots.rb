class CreateTaskSlots < ActiveRecord::Migration
  def change
    create_table :task_slots do |t|
      t.integer :task_id

	  t.timestamp :start_time
	  t.timestamp :stop_time      

      t.timestamps
    end
  end
end
