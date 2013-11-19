class TaskDetailsController < ApplicationController

  def create
    t = TaskDetail.new
    t.task_action = TaskAction.find(params[:task_action_id])
    t.name = params[:name]
    t.save!

    flash[:success] = "Task Detail Created"
    redirect_to task_project_task_action_url(TaskProject.find(params[:task_project_id]), t.task_action)
  end

  def new
    @task_project = TaskProject.find(params[:task_project_id])
    @task_action = TaskAction.find(params[:task_action_id])
  end

  def show
    @task_project = TaskProject.find(params[:task_project_id])
    @task_action = TaskAction.find(params[:task_action_id])
    @task_detail = TaskDetail.find(params[:id])
  end

  def edit
    @task_project = TaskProject.find(params[:task_project_id])
    @task_action = TaskAction.find(params[:task_action_id])
    @task_detail = TaskDetail.find(params[:id])
  end

  def update
    t = TaskDetail.find(params[:id])
    t.task_action = TaskAction.find(params[:task_action_id])
    t.name = params[:name]
    t.save!

    flash[:success] = "Task Detail Updated"
    redirect_to task_project_task_action_task_detail_url(TaskProject.find(params[:task_project_id]), t.task_action, t.id)
  end

  def destroy
    t = TaskDetail.find(params[:id])
    t.delete

    flash[:success] = "Task Detail Deleted"
    redirect_to task_project_task_action_url(TaskProject.find(params[:task_project_id]), TaskAction.find(params[:task_action_id]))
  end

end
