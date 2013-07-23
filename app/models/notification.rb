class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :contact
  belongs_to :task

  before_save do
    self.task_name = self.task.name if self.task
    self.contact_name = self.contact.name if self.contact
    self.emailed = not(self.user.receive_emails)
    true
  end

  after_destroy do
  	unless self.user.updates_for_task? self.task
  		self.task.updated = false
  		self.task.save
  	end
  	unless self.user.updates_for_contact? self.contact 
  		self.contact.updated = false
  		self.contact.save
  	end
  end
end