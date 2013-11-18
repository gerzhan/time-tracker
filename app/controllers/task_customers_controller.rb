class TaskCustomersController < ApplicationController
  
  def index
    @task_customers = TaskCustomer.order(:name)
  end

  def create
    t = TaskCustomer.new
    t.name = params[:name]
    t.save!

    flash[:success] = "Task Customer Created"
    redirect_to task_customers_url
  end

  def new
  end

  def show
    @task_customer = TaskCustomer.find(params[:id])
  end

  def edit
    @task_customer = TaskCustomer.find(params[:id])
  end

  def update
    t = TaskCustomer.find(params[:id])
    t.name = params[:name]
    t.save!

    flash[:success] = "Task Customer Updated"
    redirect_to task_customer_url(t.id)
  end

  def destroy
    t = TaskCustomer.find(params[:id])
    t.delete

    flash[:success] = "Task Customer Deleted"
    redirect_to task_customers_url
  end

end
