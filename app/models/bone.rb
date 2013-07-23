class Bone < ActiveRecord::Base
  belongs_to :giver, class_name: 'User'
  belongs_to :taker, class_name: 'User'
  belongs_to :task
  
  before_save do
    self.task_name = self.task.name
    true
  end

  def notify_sent
    notification = Notification.new(
        :action => 'sent_bone',
        :user => self.taker,
        :contact => self.giver.user_as_contact_for(self.taker),
        :task => self.task,
        :task_name => self.task_name,
        :amount => self.amount)
    if existing_notification = taker.existing_notification(notification)
      existing_notification.amount = self.amount
      existing_notification.save
    else
      notification.save
    end
  end
end