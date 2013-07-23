class Invite < ActiveRecord::Base
	belongs_to :contact
	belongs_to :task
  belongs_to :user

	before_create do
    self.user = self.contact.referenced_user
		self.pending = true   
    true
  end

  before_save do
    self.unread = false
    true
  end

  after_save do
    if self.contact.referenced_user
      GoogleEvent.where(
      	task_id: self.task.id,
      	user_id: self.contact.referenced_user.id).destroy_all
    end    
  end
end