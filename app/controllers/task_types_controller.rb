class TaskTypesController < ApplicationController

  def index
    @task_types = TaskType.order(:name)
  end

  def create
    t = TaskType.new
    t.name = params[:name]
    t.save!

    flash[:success] = "Task Type Created"
    redirect_to task_types_url
  end

  def new
  end

  def show
    @task_type = TaskType.find(params[:id])
  end

  def edit
    @task_type = TaskType.find(params[:id])
  end

  def update
    t = TaskType.find(params[:id])
    t.name = params[:name]
    t.save!

    flash[:success] = "Task Type Updated"
    redirect_to task_type_url(t.id)
  end

  def destroy
    t = TaskType.find(params[:id])
    t.delete

    flash[:success] = "Task Type Deleted"
    redirect_to task_types_url
  end

end
