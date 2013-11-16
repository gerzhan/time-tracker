class CreateTimeRequests < ActiveRecord::Migration
  def change
    create_table :time_requests do |t|
      t.string  :name
      t.string  :comment
      t.integer :time_request_type_id
      t.integer :user_id
      
      t.timestamp :from
      t.timestamp :to

      t.timestamps
    end
  end
end
