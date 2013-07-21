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

  def delete
    if @current_user
      @task = Task.find_by_id params[:id]
      @status.error = "Acceso denegado" and return unless @current_user.owns_task? @task
      @task.notify_deleted
      @task.destroy
      @status.info = "Se ha eliminado la tarea #{@task.name}."
    end
  end

  def update
    if @current_user
      @task = Task.find_by_id params[:task][:id]
      @status.error = "Acceso denegado" and return unless @current_user.owns_task? @task
      if @task.update_attributes params[:task]
        @task.notify_updated
        @status.info = "Se ha actualizado la tarea #{@task.name}."
      else
        @status.error = "Se ha producido un error al modificar la tarea #{@task.name}."
      end
    end
  end

  def complete
    if @current_user
      @task = Task.find_by_id params[:id]
      @status.error = "Acceso denegado" and return unless @current_user.owns_task? @task
      @task.mark_as_completed
      @status.info = "La tarea #{@task.name} se ha marcado como completada."
    end
  end

  def postpone
    if @current_user
      @task = Task.find_by_id params[:id]
      @status.error = "Acceso denegado" and return unless @current_user.owns_task? @task
      @task.deadline = Time.now.localtime.to_date + 1
      @task.save
      @task.mark_as_updated
      @task.clear_notify_date
    end
  end

end