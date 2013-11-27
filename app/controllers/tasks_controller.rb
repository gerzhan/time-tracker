class TasksController < ApplicationController
  
  def index
      @tasks = Task.where("user_id = ? and task_status_id in (?)", current_user, [TaskStatus.STARTED, TaskStatus.RESUMED, TaskStatus.PAUSED, TaskStatus.SCHEDULED]).page(params[:page])
  end

  def scheduled_new
      @types = TaskType.order(:name)
      @customers = TaskCustomer.order(:name)
      @projects = TaskProject.order(:name)
      @actions = TaskAction.order(:name)
      @details = TaskDetail.order(:name)
  end

  def new
      @types = TaskType.order(:name)
      @customers = TaskCustomer.order(:name)
      @projects = TaskProject.order(:name)
      @actions = TaskAction.order(:name)
      @details = TaskDetail.order(:name)
  end

  def scheduled_create
    t = Task.new
    t.name = params[:name]
    t.comment = params[:comment]
    t.scheduled_for = DateTime.strptime(params[:scheduled_for], "%m/%d/%Y %H:%M")
    t.task_type = (params[:task_type] != "" ? TaskType.find(params[:task_type]) : nil)
    t.task_customer = (params[:task_customer] != "" ? TaskCustomer.find(params[:task_customer]) : nil)
    t.task_project = (params[:task_project] != "" ? TaskProject.find(params[:task_project]) : nil)
    t.task_action = (params[:task_action] != "" ? TaskAction.find(params[:task_action]) : nil)
    t.task_detail = (params[:task_detail] != "" ? TaskDetail.find(params[:task_detail]) : nil)
    t.user = current_user
    t.task_status = TaskStatus.SCHEDULED
    t.save!

    flash[:success] = "Scheduled New Task"
    redirect_to tasks_url
  end

  def create
    t = Task.new
    t.name = params[:name]
    t.comment = params[:comment]
    t.scheduled_for = DateTime.now
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

  def scheduled_show
    @task = Task.find(params[:id])

    if @task.user != current_user
      not_authorized
    end
  end

  def show
    @task = Task.find(params[:id])

    if @task.user != current_user
      not_authorized
    end
  end

  def scheduled_edit
    @task = Task.find(params[:id])

    if @task.user != current_user
      not_authorized
    end

    @types = TaskType.order(:name)
    @customers = TaskCustomer.order(:name)
    @projects = TaskProject.order(:name)
    @actions = TaskAction.order(:name)
    @details = TaskDetail.order(:name)
  end

  def edit
    @task = Task.find(params[:id])

    if @task.user != current_user
      not_authorized
    end

    @types = TaskType.order(:name)
    @customers = TaskCustomer.order(:name)
    @projects = TaskProject.order(:name)
    @actions = TaskAction.order(:name)
    @details = TaskDetail.order(:name)
  end

  def scheduled_update
    t = Task.find(params[:id])

    if t.user != current_user
      not_authorized
    end

    t.name = params[:name]
    t.comment = params[:comment]
    t.scheduled_for = DateTime.strptime(params[:scheduled_for], "%m/%d/%Y %H:%M")
    t.task_type = (params[:task_type] != "" ? TaskType.find(params[:task_type]) : nil)
    t.task_customer = (params[:task_customer] != "" ? TaskCustomer.find(params[:task_customer]) : nil)
    t.task_project = (params[:task_project] != "" ? TaskProject.find(params[:task_project]) : nil)
    t.task_action = (params[:task_action] != "" ? TaskAction.find(params[:task_action]) : nil)
    t.task_detail = (params[:task_detail] != "" ? TaskDetail.find(params[:task_detail]) : nil)
    t.user = current_user
    t.task_status = TaskStatus.STARTED
    t.save!

    flash[:success] = "Task Updated"
    redirect_to task_url(t.id)
  end

  def update
    t = Task.find(params[:id])

    if t.user != current_user
      not_authorized
    end

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

    flash[:success] = "Task Updated"
    redirect_to task_url(t.id)
  end

  def scheduled_destroy
    t = Task.find(params[:id])

    if t.user != current_user
      not_authorized
    end

    t.delete

    flash[:success] = "Scheduled Task Deleted"
    redirect_to tasks_url
  end

  def duplicate
    to = Task.find(params[:id])

    if to.user != current_user && to.task_status != TaskStatus.COMPLETED
      not_authorized
    end

    t = Task.new
    t.name = to.name
    t.comment = to.comment
    t.scheduled_for = DateTime.now
    t.task_type = to.task_type
    t.task_customer = to.task_customer
    t.task_project = to.task_project
    t.task_action = to.task_action
    t.task_detail = to.task_detail
    t.user = current_user
    t.task_status = TaskStatus.STARTED
    t.save!

    ts = TaskSlot.new
    ts.task = t
    ts.start_time = Time.now
    ts.save!

    flash[:success] = "Duplicted Task"
    redirect_to tasks_url
  end

  def pause
    t = Task.find(params[:id])

    if t.user != current_user
      not_authorized
    end

    t.task_status = TaskStatus.PAUSED
    t.save!

    ts = t.task_slot.last
    ts.stop_time = Time.now
    ts.save!

    flash[:notice] = "Task Started"
    redirect_to :back
  end

  def resume
    t = Task.find(params[:id])

    if t.user != current_user
      not_authorized
    end

    t.task_status = TaskStatus.RESUMED
    t.save!

    ts = TaskSlot.new
    ts.task = t
    ts.start_time = Time.now
    ts.save!

    flash[:notice] = "Task Resumed"
    redirect_to :back
  end

  def stop
    t = Task.find(params[:id])

    if t.user != current_user
      not_authorized
    end
    
    t.task_status = TaskStatus.COMPLETED
    t.save!

    ts = t.task_slot.last
    if ts.stop_time == nil
      ts.stop_time = Time.now
    end
    ts.save!

    flash[:notice] = "Task Completed"
    redirect_to tasks_url
  end

  def history
    @start = Date.today - Date.today.wday
    @end = @start + 7.days

    if !params[:start] || params[:start] == ""
      params[:start] = @start.strftime("%m/%d/%Y")
    end
    if !params[:end] || params[:end] == ""
      params[:end] = @end.strftime("%m/%d/%Y")
    end

    @tasks = Task.where("user_id = ? and task_status_id = ? and created_at >= ? and updated_at <= ?", current_user, TaskStatus.COMPLETED, Date.strptime(params[:start], "%m/%d/%Y"), Date.strptime(params[:end], "%m/%d/%Y"))

    @data = {}
    @tasks.each { |task|
      if !@data["#{task.task_project.name} #{task.task_action.name} for #{task.task_customer.name}"]
        @data["#{task.task_project.name} #{task.task_action.name} for #{task.task_customer.name}"] = 0
      end

      sum = 0.0
      task.task_slot.each { |ts|
        sum += ((ts.stop_time - ts.start_time) / 3600).round(2)
      }

      @data["#{task.task_project.name} #{task.task_action.name} for #{task.task_customer.name}"] += sum
    }

    @tasks = @tasks.page(params[:page])
  end
end
