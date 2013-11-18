class TaskProjectsController < ApplicationController
  
  def index
    @task_projects = TaskProject.order(:name)
  end

  def create
    t = TaskProject.new
    t.name = params[:name]
    t.save!

    flash[:success] = "Task Project Created"
    redirect_to task_projects_url
  end

  def new
  end

  def show
    @task_project = TaskProject.find(params[:id])
  end

  def edit
    @task_project = TaskProject.find(params[:id])
  end

  def update
    t = TaskProject.find(params[:id])
    t.name = params[:name]
    t.save!

    flash[:success] = "Task Project Updated"
    redirect_to task_project_url(t.id)
  end

  def destroy
    t = TaskProject.find(params[:id])
    t.delete

    flash[:success] = "Task Project Deleted"
    redirect_to task_projects_url
  end

end
