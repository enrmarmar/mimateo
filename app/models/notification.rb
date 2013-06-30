class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :contact
  belongs_to :task

  before_save do
    self.task_name = self.task.name if self.task
    self.contact_name = self.contact.name if self.contact
  end

end