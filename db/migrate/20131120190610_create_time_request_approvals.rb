class CreateTimeRequestApprovals < ActiveRecord::Migration
  def change
    create_table :time_request_approvals do |t|
	  t.integer :user_id
	  t.integer :time_request_id
      t.boolean :approved
      t.boolean :rejected

      t.timestamps
    end
  end
end
