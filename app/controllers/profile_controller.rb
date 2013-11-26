class ProfileController < ApplicationController

	def index
	end

	def update_password
		user = login(current_user.username, params[:current_password])
		if user
			if params[:new_password] == params[:confirm_password]
				user.change_password!(params[:confirm_password])

				flash[:success] = "Password Updated"
				redirect_to :back
			else
				flash[:error] = "Passwords Do Not Match"
				redirect_to :back
			end
		else
			flash[:error] = "Old Password Incorrect"
			redirect_to :back
		end
	end

	def update_profile
		current_user.first_name = params[:first_name]
		current_user.last_name = params[:last_name]
		current_user.username = params[:username]
		current_user.email = params[:email]
		current_user.save!

		flash[:success] = "Profile Updated"
		redirect_to :back
	end

end
