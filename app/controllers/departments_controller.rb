class DepartmentsController < ApplicationController
  def index
    @departments = Department.order(:name)
  end

  def create
    d = Department.new
    d.name = params[:name]
    d.manager = params[:manager] != "" ? User.find(params[:manager]) : nil
    d.save!

    flash[:success] = "Department Created"
    redirect_to departments_url
  end

  def new
    @users = User.order(:username)
  end

  def show
    @department = Department.find(params[:id])
    @time_request_approvers = TimeRequestApprover.where(department: @department)
  end

  def edit
    @department = Department.find(params[:id])
    @users = User.order(:username)
  end

  def update
    d = Department.find(params[:id])
    d.name = params[:name]
    d.manager = params[:manager] != "" ? User.find(params[:manager]) : nil
    d.save!

    flash[:success] = "Department Updated"
    redirect_to department_url(d.id)
  end

  def destroy
    d = Department.find(params[:id])
    d.delete

    flash[:success] = "Department Deleted"
    redirect_to departments_url
  end
end
