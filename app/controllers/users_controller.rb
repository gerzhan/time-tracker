class UsersController < ApplicationController
  
  def index
    @users = User.order(:username)
  end

  def new
    @roles = Role.order(:name)
    @departments = Department.order(:name)
  end

  def create
    u = User.new
    u.username = params[:username]
    u.email = params[:email]
    u.department = params[:department] != "" ? Department.find(params[:department]) : nil
    u.role = params[:role] != "" ? Role.find(params[:role]) : nil
    u.yearly_pto_hour_allotment = params[:yearly_pto_hour_allotment]
    u.password = "changeme"
    u.save!

    UserMailer.welcome_email(u).deliver

    flash[:success] = "User Created"
    redirect_to users_url
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
    @roles = Role.order(:name)
    @departments = Department.order(:name)
  end

  def update
    u = User.find(params[:id])
    u.username = params[:username]
    u.email = params[:email]
    u.department = params[:department] != "" ? Department.find(params[:department]) : nil
    u.role = params[:role] != "" ? Role.find(params[:role]) : nil
    u.yearly_pto_hour_allotment = params[:yearly_pto_hour_allotment]
    u.save!

    flash[:success] = "User Updated"
    redirect_to user_url(u.id)
  end

  def destroy
    u = User.find(params[:id])
    u.delete

    flash[:success] = "User Deleted"
    redirect_to users_url
  end

end
