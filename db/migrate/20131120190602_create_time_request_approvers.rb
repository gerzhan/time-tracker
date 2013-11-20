class CreateTimeRequestApprovers < ActiveRecord::Migration
  def change
    create_table :time_request_approvers do |t|
      t.integer :department_id
      t.integer :time_request_type_id
      t.integer :user_id

      t.timestamps
    end
  end
end
