class Api::V1::TasksController < ApplicationController
  def index
    @current_user = User.first
    @tasks = @current_user.active_tasks
    render :json => @tasks
  end
end