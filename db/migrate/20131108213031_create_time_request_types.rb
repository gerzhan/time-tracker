class CreateTimeRequestTypes < ActiveRecord::Migration
  def change
    create_table :time_request_types do |t|
      t.string :name

      t.timestamps
    end

    t = TimeRequestType.new
    t.name = "PTO"
    t.save!

	t = TimeRequestType.new
    t.name = "Out of Office"
    t.save!    
  end
end
