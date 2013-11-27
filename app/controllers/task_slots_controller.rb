class TaskSlotsController < ApplicationController

	def new
		@task = Task.find(params[:task_id])
	end

	def create
		task = Task.find(params[:task_id])
		t = TaskSlot.new
		t.task = task
		t.start_time = DateTime.strptime(params[:start_time], "%m/%d/%Y %H:%M")
		t.stop_time = DateTime.strptime(params[:stop_time], "%m/%d/%Y %H:%M")
		t.save!

		flash[:success] = "Task Slot Created"
		redirect_to task_url(task)
	end

	def show
		@task = Task.find(params[:task_id])
		@task_slot = TaskSlot.find(params[:id])
	end

	def edit
		@task = Task.find(params[:task_id])
		@task_slot = TaskSlot.find(params[:id])
	end

	def update
		task = Task.find(params[:task_id])
		t = TaskSlot.find(params[:id])
		t.start_time = DateTime.strptime(params[:start_time], "%m/%d/%Y %H:%M")
		t.stop_time = DateTime.strptime(params[:stop_time], "%m/%d/%Y %H:%M")
		t.save!

		flash[:success] = "Task Slot Updated"
		redirect_to task_task_slot_url(task, t)
	end

	def destroy
		task = Task.find(params[:task_id])
		t = TaskSlot.find(params[:id])
		t.delete

		flash[:success] = "Task Slot Deleted"
		redirect_to task_url(task)
	end

end
