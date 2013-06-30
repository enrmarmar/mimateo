class Bone < ActiveRecord::Base
  belongs_to :giver, class_name: 'User'
  belongs_to :taker, class_name: 'User'
  belongs_to :task
  
  before_save do
    self.task_name = self.task.name
  end

  def notify_sent
    notification = Notification.new
    notification.action = 'sent_bone'
    notification.user = self.taker
    notification.contact = self.giver.user_as_contact_for self.taker
    notification.task = self.task
    notification.task_name = self.task_name
    notification.amount = self.amount
    unless existing_notification = taker.existing_notification(notification)
      notification.save
    else
      existing_notification.amount = self.amount
      existing_notification.save
    end
  end
end