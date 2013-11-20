class TimeRequestApproversController < ApplicationController
  def create
    department = Department.find(params[:department_id])

    tra = TimeRequestApprover.new
    tra.user = params[:user] != "" ? User.find(params[:user]) : nil
    tra.time_request_type = params[:time_request_type] != "" ? TimeRequestType.find(params[:time_request_type]) : nil
    tra.department = department
    tra.save!

    flash[:success] = "Time Request Approver Created"
    redirect_to department_url(department.id)
  end

  def new
    @department = Department.find(params[:department_id])
    @users = User.order(:username)
    @time_request_types = TimeRequestType.order(:name)
  end

  def show
    @department = Department.find(params[:department_id])
    @time_request_approver = TimeRequestApprover.find(params[:id])
  end

  def edit
    @department = Department.find(params[:department_id])
    @users = User.order(:username)
    @time_request_types = TimeRequestType.order(:name)
    @time_request_approver = TimeRequestApprover.find(params[:id])
  end

  def update
    department = Department.find(params[:department_id])

    tra = TimeRequestApprover.find(params[:id])
    tra.user = params[:user] != "" ? User.find(params[:user]) : nil
    tra.time_request_type = params[:time_request_type] != "" ? TimeRequestType.find(params[:time_request_type]) : nil
    tra.save!

    flash[:success] = "Time Request Approver Updated"
    redirect_to department_time_request_approver_url(department, tra.id)
  end

  def destroy
    department = Department.find(params[:department_id])

    tra = TimeRequestApprover.find(params[:id])
    tra.delete

    flash[:success] = "Time Request Approver Deleted"
    redirect_to department_url(department.id)
  end
end
