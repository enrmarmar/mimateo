class NotificationsController < ApplicationController
  def destroy
    @notification = Notification.find_by_id params[:id]
    access_denied and return unless @notification.user == @current_user
    @notification.destroy
    unmark_as_updated_if_last_notification
    render :nothing => true and return  if request.xhr?
    redirect_to :back
  end

  def unmark_as_updated_if_last_notification
  	unless @notification.user.updates_for_task? @notification.task
  		@notification.task.unmark_as_updated
      flash[:reload] = true # For AJAX requests
  	end
  	unless @notification.user.updates_for_contact? @notification.contact 
  		@notification.contact.updated = false
  		@notification.contact.save
      flash[:reload] = true # For AJAX requests
  	end
  end
end