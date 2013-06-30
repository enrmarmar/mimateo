class MessagesController < ApplicationController
	def create
    @message = Message.new params[:message]
    @task = Task.find_by_id @message.task_id
    access_denied and return unless @current_user.owns_task?(@task) || @current_user.is_invited_to_task?(@task)
    access_denied and return if @task.pending_for? @current_user
    
    @message.user = @current_user
    if @message.save
    	flash[:notice] = "Mensaje publicado"
      @message.notify_unread
      @message.task.mark_as_unread
      @message.task.mark_as_read_for @current_user
    else
      flash[:warning] = "Ha habido un error al publicar el mensaje"
    end
    redirect_to task_path @message.task
  end

  def destroy
    @message = Message.find_by_id params[:id]
		access_denied unless @current_user.owns_task? @message.task
		@message.text = "<< Mensaje eliminado por " + @current_user.name + " >>"
		if @message.save
			flash[:notice] = "Se ha eliminado el mensaje."
      @message.task.mark_as_unread
      @message.task.mark_as_read_for @current_user
    else
    	flash[:warning] = "Ha habido un error al eliminar el mensaje."
    end
    redirect_to task_path @message.task
  end
end