class TasksController < ApplicationController
  
  def index
      @tasks = Task.where("user_id = ? and task_status_id in (?)", current_user, [TaskStatus.STARTED, TaskStatus.RESUMED])
  end

  def new
      @types = TaskType.order(:name)
      @customers = TaskCustomer.order(:name)
      @projects = TaskProject.order(:name)
      @actions = TaskAction.order(:name)
      @details = TaskDetail.order(:name)
  end

  def create
    t = Task.new
    t.name = params[:name]
    t.comment = params[:comment]
    t.task_type = (params[:task_type] != "" ? TaskType.find(params[:task_type]) : nil)
    t.task_customer = (params[:task_customer] != "" ? TaskCustomer.find(params[:task_customer]) : nil)
    t.task_project = (params[:task_project] != "" ? TaskProject.find(params[:task_project]) : nil)
    t.task_action = (params[:task_action] != "" ? TaskAction.find(params[:task_action]) : nil)
    t.task_detail = (params[:task_detail] != "" ? TaskDetail.find(params[:task_detail]) : nil)
    t.user = current_user
    t.task_status = TaskStatus.STARTED
    t.save!

    ts = TaskSlot.new
    ts.task = t
    ts.start_time = Time.now
    ts.save!

    flash[:success] = "Started New Task"
    redirect_to tasks_url
  end

  def show
  end

  def edit
  end

  def update
  end

  def destroy
  end

  def history
  end
end
