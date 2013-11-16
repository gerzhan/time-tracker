class CreateTaskProjects < ActiveRecord::Migration
  def change
    create_table :task_projects do |t|
      t.string :name

      t.timestamps
    end

    t = TaskProject.new 
	t.name = "BlackBeard"
	t.save!

	t = TaskProject.new 
	t.name = "Jira"
	t.save!

	t = TaskProject.new 
	t.name = "Legacy"
	t.save!

	t = TaskProject.new 
	t.name = "Network"
	t.save!

	t = TaskProject.new 
	t.name = "Powderroom"
	t.save!

	t = TaskProject.new 
	t.name = "Rater"
	t.save!

	t = TaskProject.new 
	t.name = "Roadmap"
	t.save!

	t = TaskProject.new 
	t.name = "Translator"
	t.save!

	t = TaskProject.new 
	t.name = "Vendor Portal"
	t.save!

  end
end
