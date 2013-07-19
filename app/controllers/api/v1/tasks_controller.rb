class Api::V1::TasksController < Api::V1::BaseController
  def tasks
  	if @current_user
    	@tasks = @current_user.tasks
  	end
  end
end