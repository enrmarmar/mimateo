class Message < ActiveRecord::Base
	belongs_to :user
	belongs_to :task

  def notify_unread
    notify_unread_for self.task.user
    self.task.contacts.each do |contact|
      self.notify_unread_for contact.referenced_user
    end
  end

  def notify_unread_for user
    unless user == self.user
      notification = Notification.new
      notification.action = 'unread_message'
      notification.user = user
      notification.task = self.task
      notification.task_name = self.task.name
      notification.amount = 1
      unless existing_notification = user.existing_notification(notification)
        notification.save
      else
        existing_notification.amount += 1
        existing_notification.save
      end
    end
  end

end