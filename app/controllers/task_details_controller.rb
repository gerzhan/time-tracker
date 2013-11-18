class TaskDetailsController < ApplicationController

def index
    @task_details = TaskDetail.order(:name)
  end

  def create
    t = TaskDetail.new
    t.name = params[:name]
    t.save!

    flash[:success] = "Task Detail Created"
    redirect_to task_details_url
  end

  def new
  end

  def show
    @task_detail = TaskDetail.find(params[:id])
  end

  def edit
    @task_detail = TaskDetail.find(params[:id])
  end

  def update
    t = TaskDetail.find(params[:id])
    t.name = params[:name]
    t.save!

    flash[:success] = "Task Detail Updated"
    redirect_to task_detail_url(t.id)
  end

  def destroy
    t = TaskDetail.find(params[:id])
    t.delete

    flash[:success] = "Task Detail Deleted"
    redirect_to task_details_url
  end

end
