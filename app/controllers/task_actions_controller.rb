class TaskActionsController < ApplicationController
  
  def index
    @task_actions = TaskAction.order(:name)
  end

  def create
    t = TaskAction.new
    t.name = params[:name]
    t.save!

    flash[:success] = "Task Action Created"
    redirect_to task_actions_url
  end

  def new
  end

  def show
    @task_action = TaskAction.find(params[:id])
  end

  def edit
    @task_action = TaskAction.find(params[:id])
  end

  def update
    t = TaskAction.find(params[:id])
    t.name = params[:name]
    t.save!

    flash[:success] = "Task Action Updated"
    redirect_to task_action_url(t.id)
  end

  def destroy
    t = TaskAction.find(params[:id])
    t.delete

    flash[:success] = "Task Action Deleted"
    redirect_to task_actions_url
  end
  
end
