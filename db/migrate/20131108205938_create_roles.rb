class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :name
      
      t.timestamps
    end

    r = Role.new
    r.name = "USER"
    r.save!

    r = Role.new
    r.name = "MANAGER"
    r.save!

    r = Role.new
    r.name = "ADMIN"
    r.save!
  end
end
