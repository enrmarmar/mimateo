# encoding: UTF-8

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
      @bones_given_to_contact = @current_user.given_bones.where(:taker_id => @user.id)
      @number_of_bones_given_to_contact = @bones_given_to_contact.sum(:amount)
      @bones_taken_from_contact = @current_user.taken_bones.where(:giver_id => @user.id)
      @number_of_bones_taken_from_contact = @bones_taken_from_contact.sum(:amount)
    end
    @pendingTasks = @current_user.pending_invited_tasks.where(user_id: @contact.referenced_user.id)
  end

  def create
    access_denied and return unless @current_user
  	@contact = Contact.new(params[:contact])
  	@contact.user = @current_user
    if @contact.save
      # Create a pending contact for the referenced user unless already a contact
      if User.find_by_email(@contact.email)
        unless @contact.referenced_user.user_as_contact_for(@current_user)
          @referenced_contact = Contact.create!(
            :user => @contact.referenced_user,
            :name => @current_user.name, 
            :email => @current_user.email, 
            :pending => true)
        end
        flash[:notice] = "Se ha creado el contacto #{@contact.name}."
      else
        UserMailer.invite_email(@contact, @current_user).deliver
        @contact.destroy
        flash[:notice] = "Se ha enviado un email de invitación a #{@contact.email}."
      end
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