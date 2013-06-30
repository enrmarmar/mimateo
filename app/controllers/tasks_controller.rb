class TasksController < ApplicationController

  def index
    @tasks = @current_user.tasks + @current_user.active_invited_tasks.to_a
    @pendingTasks = @current_user.pending_invited_tasks
    @pendingContacts = @current_user.pending_contacts
    @notifications = @current_user.notifications
  end

  def show
  	@task = Task.find_by_id(params[:id])
    access_denied and return unless @current_user.owns_task?(@task) || @current_user.is_invited_to_task?(@task)
    access_denied and return if @task.pending_for? @current_user
    @task.mark_as_read_for @current_user
    @sideTasks = @current_user.tasks + @current_user.active_invited_tasks.to_a
    @notifications = @current_user.notifications.where(:task_id => @task)
  end

  def create
    access_denied and return unless @current_user
  	@task = Task.new params[:task]
    @task.user_id = @current_user.id
    if @task.save
    	flash[:notice] = "Se ha creado la tarea #{@task.name}."
    	redirect_to task_path @task
    else
      render 'new'
    end
  end

  def new
    access_denied and return unless @current_user
    @task = Task.new
  end

  def edit
    @task = Task.find_by_id params[:id]
    access_denied and return unless @current_user.owns_task? @task
  end

  def update
    @task = Task.find_by_id params[:id]
    access_denied and return unless @current_user.owns_task? @task
    if @task.update_attributes params[:task]
      @task.mark_as_updated
      @task.notify_updated
      flash[:notice] = "Se ha actualizado la tarea #{@task.name}."
      redirect_to task_path @task
    else
      render 'edit'
    end
  end

  def destroy
    @task = Task.find_by_id params[:id]
    access_denied and return unless @current_user.owns_task? @task
    @task.notify_deleted
    @task.destroy
    flash[:notice] = "Se ha eliminado la tarea #{@task.name}."
    redirect_to tasks_path
  end

  def complete
    @task = Task.find_by_id params[:id]
    access_denied and return unless @current_user.owns_task? @task
    @task.completed = true
    @task.save
    @task.mark_as_updated
    @task.notify_completed
    flash[:notice] = "La tarea #{@task.name} se ha marcado como completada."
    render :nothing => true and return if request.xhr?
    redirect_to task_path @task
  end

  def uncomplete
    @task = Task.find_by_id params[:id]
    access_denied and return unless @current_user.owns_task? @task
    @task.completed = false
    @task.save
    @task.mark_as_updated
    flash[:notice] = "La tarea #{@task.name} se ha marcado como pendiente."
    render :nothing => true and return if request.xhr?
    redirect_to task_path @task
  end

  def invite
    @task = Task.find_by_id params[:id]
    access_denied and return unless @current_user.owns_task? @task
    @contact = Contact.find_by_id params[:contact]
    @user = User.find_by_id @contact.referenced_user_id
    @referenced_contact = @user.contacts.find_by_referenced_user_id @current_user.id
    if @user == @current_user
      flash[:warning] = "No puedes invitarte a ti mismo!"
    elsif @user.is_invited_to_task? @task
      flash[:warning] = "El usuario #{@contact.name} ya estaba invitado a #{@task.name}"
    else
      @task.contacts << @contact
      @task.save
      @task.mark_as_pending_for @user
      @referenced_contact.updated = true
      @referenced_contact.save
      flash[:notice] = "#{@contact.name} invitado a #{@task.name}"
    end
    render :nothing => true and return if request.xhr?
    redirect_to :back
  end

  def uninvite
    @task = Task.find_by_id params[:id]
    @contact = Contact.find_by_id params[:contact]
    access_denied and return unless @current_user.owns_task? @task
    @task.invites.find_by_contact_id(@contact.id).destroy
    flash[:notice] = "#{@contact.name} expulsado de #{@task.name}"
    render :nothing => true and return if request.xhr?
    redirect_to :back
  end

  def accept
    @task = Task.find_by_id params[:id]
    access_denied and return unless @current_user.is_invited_to_task? @task
    @task.unmark_as_pending_for @current_user
    @task.save
    flash[:notice] = "Se ha aceptado la tarea #{@task.name}"
    redirect_to task_path(@task)
  end

  def refuse
    @task = Task.find_by_id params[:id]
    access_denied and return unless @current_user.is_invited_to_task? @task
    @task.destroy_invitation_for @current_user
    flash[:notice] = "Se ha rechazado la tarea #{@task.name}"
    render :nothing => true and return if request.xhr?
    redirect_to tasks_path
  end
    
end