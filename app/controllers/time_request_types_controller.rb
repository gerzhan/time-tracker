class TimeRequestTypesController < ApplicationController
  
  def index
    @time_request_types = TimeRequestType.order(:name)
  end

  def create
    t = TimeRequestType.new
    t.name = params[:name]
    t.save!

    flash[:success] = "Time Request Type Created"
    redirect_to time_request_types_url
  end

  def new
  end

  def show
    @time_request_type = TimeRequestType.find(params[:id])
  end

  def edit
    @time_request_type = TimeRequestType.find(params[:id])
  end

  def update
    t = TimeRequestType.find(params[:id])
    t.name = params[:name]
    t.save!

    flash[:success] = "Time Request Type Updated"
    redirect_to time_request_type_url(t.id)
  end

  def destroy
    t = TimeRequestType.find(params[:id])
    t.delete

    flash[:success] = "Time Request Type Deleted"
    redirect_to time_request_types_url
  end

end
