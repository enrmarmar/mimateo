class Invite < ActiveRecord::Base
	belongs_to :contact
	belongs_to :task

  after_save do
    if self.contact.referenced_user
      GoogleEvent.where(
      	task_id: self.task.id,
      	user_id: self.contact.referenced_user.id).destroy_all
    end    
  end
end