class Message < ActiveRecord::Base
	belongs_to :user
	belongs_to :task

  after_save do
    self.task.unread = true
  end

  def notify_unread
    notify_unread_for self.task.user
    self.task.contacts.each do |contact|
      self.notify_unread_for contact.referenced_user
    end
  end

  def notify_unread_for user
    unless user == self.user
      notification = Notification.new(
        :action => 'unread_message',
        :user => user,
        :task => self.task,
        :task_name => self.task.name,
        :amount => 1)
      unless existing_notification = user.existing_notification(notification)
        notification.save
      else
        existing_notification.amount += 1
        existing_notification.save
      end
    end
  end

end