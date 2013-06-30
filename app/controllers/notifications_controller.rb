class NotificationsController < ApplicationController
  def destroy
    @notification = Notification.find_by_id params[:id]
    access_denied and return unless @notification.user == @current_user
    @notification.destroy
    render :nothing => true and return  if request.xhr?
    redirect_to :back
  end
end