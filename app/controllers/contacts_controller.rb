class ContactsController < ApplicationController

  def show
    @contact = Contact.find_by_id(params[:id])
    access_denied and return unless @current_user.contacts.include? @contact
    @tasks = @contact.tasks
    @contact.updated = false
    @contact.save
    @sideContacts = @current_user.active_contacts
    @notifications = @contact.notifications
    if @user = @contact.referenced_user
      @bones_given_to_contact = @current_user.given_bones.where(:taker_id => @user.id).sum(:amount)
      @bones_taken_from_contact = @current_user.taken_bones.where(:giver_id => @user.id).sum(:amount)
    end
    # @notifications = @current_user.notifications.where(:contact_id => @contact)
  end

  def create
    access_denied and return unless @current_user
  	@contact = Contact.new(params[:contact])
  	@contact.user = @current_user
    if @contact.save
      # Create a pending contact for the referenced user
      if User.find_by_email(@contact.email)
        unless @contact.referenced_user.user_as_contact(@current_user)
          @referenced_contact = Contact.new
          @referenced_contact.user = @contact.referenced_user
          @referenced_contact.name = @current_user.name
          @referenced_contact.email = @current_user.email
          @referenced_contact.pending = true
          @referenced_contact.save
        end
      end
  	  flash[:notice] = "Se ha creado el contacto #{@contact.name}."
  	  redirect_to tasks_path
  	else
  	  render 'new'
  	end
  end

  def new
    access_denied and return unless @current_user
    @contact = Contact.new
  end

  def edit
    @contact = Contact.find_by_id(params[:id])
    access_denied and return unless @current_user.contacts.include? @contact
  end

  def update
    @contact = Contact.find_by_id(params[:id])
    access_denied and return unless @current_user.contacts.include? @contact
    if @contact.update_attributes(params[:contact])
      flash[:notice] = "Se ha actualizado el contacto #{@contact.name}."
      redirect_to tasks_path
    else
      render 'edit'
    end
  end

  def destroy
    @contact = Contact.find_by_id(params[:id])
    access_denied and return unless @current_user.contacts.include? @contact
    @contact.notify_deleted
    @current_user.invited_tasks.each do |task|
      task.destroy if task.user == @contact.referenced_user
    end
    @contact.destroy
    flash[:notice] = "Se ha eliminado el contacto #{@contact.name}."
    redirect_to tasks_path
  end

  def accept
    @contact = Contact.find_by_id(params[:id])
    access_denied and return unless @current_user.contacts.include? @contact
    @contact.pending = false
    @contact.save
    flash[:notice] = "Se ha agregado el contacto #{@contact.name}"
    redirect_to tasks_path
  end
    
end