# encoding: UTF-8

class TasksController < ApplicationController

  def index
    @tasks = @current_user.active_tasks
    @pendingTasks = @current_user.pending_invited_tasks
    @pendingContacts = @current_user.pending_contacts
    @notifications = @current_user.notifications
  end

  def show
  	@task = Task.find_by_id(params[:id])
    access_denied and return unless @current_user.owns_task?(@task) || @current_user.is_invited_to_task?(@task)
    access_denied and return if @task.pending_for? @current_user
    @task.mark_as_read_for @current_user
    @sideTasks = @current_user.active_tasks
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
    @task.mark_as_updated
    @task.mark_as_completed
    flash[:notice] = "La tarea #{@task.name} se ha marcado como completada."
    render :nothing => true and return if request.xhr?
    redirect_to task_path @task
  end

  def postpone
    @task = Task.find_by_id params[:id]
    access_denied and return unless @current_user.owns_task? @task
    @task.deadline = Time.now.localtime.to_date + 1
    @task.save
    @task.mark_as_updated
    @task.clear_notify_date
    flash[:notice] = "La tarea #{@task.name} se ha pospuesto un dia."
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

  def invite_with_list
    @task = Task.find_by_id params[:id]
    access_denied and return unless @current_user.owns_task? @task
    @contacts = @current_user.contacts
  end

  def give_bones_with_list
    @task = Task.find_by_id params[:id]
    access_denied and return unless @current_user.owns_task? @task
    @contacts = @task.contacts
  end

  def invite
    @task = Task.find_by_id params[:id]
    access_denied and return unless @current_user
    unless @current_user.owns_task?(@task)
      access_denied
      flash[:warning] = "Sólo puede invitar el creador/a de la tarea, #{@task.user.name_for @current_user}"
      return
    end
    @contact = Contact.find_by_id params[:contact]
    @user = @contact.referenced_user
    if not(@user)
      flash[:warning] = "No puedes invitarle, ya que #{@contact.name} aún no es usuario/a de Mi Mateo"
    elsif @user == @current_user
      flash[:warning] = "No puedes invitarte a ti mismo/a!"
    elsif @user.is_invited_to_task? @task
      flash[:warning] = "#{@contact.name} ya estaba invitado/a a #{@task.name}"
    else
      if @referenced_contact = @user.contacts.find_by_referenced_user_id(@current_user.id)
        @task.contacts << @contact
        @task.save
        @task.mark_as_pending_for @user
        @referenced_contact.updated = true
        @referenced_contact.save
        flash[:notice] = "#{@contact.name} invitado/a a #{@task.name}"
      else
        flash[:warning] = "No puedes invitarle hasta que te agregue como contacto"
      end
    end
    render :nothing => true and return if request.xhr?
    redirect_to :back
  end

  def uninvite
    @task = Task.find_by_id params[:id]
    @contact = Contact.find_by_id params[:contact]
    access_denied and return unless @current_user.owns_task? @task
    @task.invites.find_by_contact_id(@contact.id).destroy
    @contact.referenced_user.notify_uninvited_from @task
    @user = @contact.referenced_user
    if @referenced_contact = @user.contacts.find_by_referenced_user_id(@current_user.id)
      @referenced_contact.updated = true
      @referenced_contact.save
    end
    flash[:notice] = "#{@contact.name} expulsado/a de #{@task.name}"
    render :nothing => true and return if request.xhr?
    redirect_to :back
  end

  def accept
    @task = Task.find_by_id params[:id]
    access_denied and return unless @current_user.is_invited_to_task? @task
    @task.unmark_as_pending_for @current_user
    @task.updated = true
    @task.save
    @task.notify_accepted_by @current_user
    @current_user.notifications.where(action: 'uninvited_task', task: @task).destroy_all
    @referenced_contact = @current_user.user_as_contact_for @task.user
    @referenced_contact.updated = true
    @referenced_contact.save
    flash[:notice] = "Se ha aceptado la tarea #{@task.name}"
    redirect_to task_path(@task)
  end

  def refuse
    @task = Task.find_by_id params[:id]
    access_denied and return unless @current_user.is_invited_to_task? @task
    @task.destroy_invitation_for @current_user
    @task.updated = true
    @referenced_contact = @current_user.user_as_contact_for @task.user
    @referenced_contact.updated = true
    @referenced_contact.save
    flash[:notice] = "Se ha rechazado la tarea #{@task.name}"
    render :nothing => true and return if request.xhr?
    redirect_to tasks_path
  end

  def check_for_updates
    last_rendered_at = params[:last_rendered_at]
    flash[:reload] = true if @current_user.updates_since? last_rendered_at
    render :nothing => true
  end
    
end
