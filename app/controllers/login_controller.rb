class LoginController < ApplicationController

	before_filter :require_login, :except => [:index, :login_user, :forgot_password, :deliver_reset_instructions, :change_password, :changed_password]

	def index
	end

	def login_user
		@user = login(params[:username], params[:password])
		if @user
			flash[:success] = "Login Successful"
			redirect_to root_url
		else
			flash[:error] = "Username/Password Incorrect"
			redirect_to login_url
		end
	end

	def logout_user
		logout
		flash[:success] = "You have been logged out"
		redirect_to login_url
	end

	def forgot_password
	end

	def deliver_reset_instructions
		@user = User.find_by_username(params[:username])

		if !@user 
			flash[:error] = "Username Not Found"
			redirect_to forgot_password_url
			return
		end

		@user.deliver_reset_password_instructions! if @user
		redirect_to(login_url, :notice => 'Instructions have been sent to your email.')
	end

	def change_password
		@user = User.load_from_reset_password_token(params[:format])

		if !@user 
			not_authenticated
			return
		end
	end

	def changed_password
		@user = User.find_by_username(params[:username])

		if !@user 
			not_authenticated
			return
		end

		if params[:password] == params[:confirm_password]
			flash[:success] = "Password Updated"
			@user.change_password!(params[:password])
			redirect_to login_url
		else
			flash[:error] = "Password Mismatch"
			redirect_to change_password_url(@user.reset_password_token)
		end
	end

end
