class Api::V1::TasksController < Api::V1::BaseController
  def tasks
  	if @current_user
    	@tasks = @current_user.tasks
  	end
  end

  def create
  	if @current_user
  		@task = Task.new params[:task]
	    @task.user_id = @current_user.id
	    if @task.save
	    	@status.info = "Se ha creado la tarea #{@task.name}."
	    else
	   		@status.error = "Se ha producido un error al crear la tarea #{@task.name}."
	    end
		end
  end
end