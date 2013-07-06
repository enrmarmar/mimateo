class BonesController < ApplicationController
  def give
    @task = Task.find_by_id(params[:id])
    @contact = Contact.find_by_id(params[:contact])
    access_denied and return unless (@current_user.contacts.include? @contact) && (@current_user.owns_task? @task)
    @giver = @current_user
    @taker = @contact.referenced_user
    unless bone = @giver.given_bones.where(:taker_id => @taker.id, :task_id => @task.id).first
      bone = Bone.new
      bone.giver = @current_user
      bone.taker = @contact.referenced_user
      bone.task = @task
      bone.amount = 1 || params[:amount]
    else
      bone.amount += 1 || params[:amount]
    end
    bone.save
    bone.notify_sent
    flash[:notice] = "Se ha mandado #{bone.amount} hueso/s a #{(bone.taker.user_as_contact_for @current_user).name}"
    render :nothing => true and return if request.xhr?
    redirect_to :back
  end
end