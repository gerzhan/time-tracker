module TasksHelper

	def options_for_actions(actions, selected = nil)
		options = ""
		actions.each do |action|
			if action == selected
				options += "<option task_project='#{action.task_project.id}' value='#{action.id}' selected='selected'>#{action.name}</option>"
			else
				options += "<option task_project='#{action.task_project.id}' value='#{action.id}'>#{action.name}</option>"
			end
		end
		options
	end

	def options_for_details(details, selected = nil)
		options = ""
		details.each do |detail|
			if detail == selected
				options += "<option task_action='#{detail.task_action.id}' value='#{detail.id}' selected='selected'>#{detail.name}</option>"
			else
				options += "<option task_action='#{detail.task_action.id}' value='#{detail.id}'>#{detail.name}</option>"
			end
		end
		options
	end

end
