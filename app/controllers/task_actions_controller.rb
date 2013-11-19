class TaskActionsController < ApplicationController

  def create
    t = TaskAction.new
    t.task_project = TaskProject.find(params[:task_project_id])
    t.name = params[:name]
    t.save!

    flash[:success] = "Task Action Created"
    redirect_to task_project_url(t.task_project)
  end

  def new
    @task_project = TaskProject.find(params[:task_project_id])
  end

  def show
    @task_action = TaskAction.find(params[:id])
    @task_project = TaskProject.find(params[:task_project_id])
    @task_details = TaskDetail.where(task_action: @task_action).order(:name)
  end

  def edit
    @task_action = TaskAction.find(params[:id])
    @task_project = TaskProject.find(params[:task_project_id])
  end

  def update
    t = TaskAction.find(params[:id])
    t.task_project = TaskProject.find(params[:task_project_id])
    t.name = params[:name]
    t.save!

    flash[:success] = "Task Action Updated"
    redirect_to task_project_task_action_url(t.task_project, t.id)
  end

  def destroy
    t = TaskAction.find(params[:id])
    t.delete

    flash[:success] = "Task Action Deleted"
    redirect_to task_project_url(TaskProject.find(params[:task_project_id]))
  end
  
end
