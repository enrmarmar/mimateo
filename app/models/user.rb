class User < ActiveRecord::Base
	validates :name, :presence=>true
	validates :email, :presence=>true, :uniqueness=>true
	validates :email, :format => { :with => /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/, :message => ": Direccion email incorrecta" }
	has_many :tasks, :dependent => :delete_all
	has_many :contacts, :dependent => :delete_all
	has_many :referenced_contacts, :class_name => "Contact", :foreign_key => "referenced_user_id"
	has_many :messages
  has_many :notifications, :dependent => :delete_all
  has_many :given_bones, class_name: 'Bone', foreign_key: 'giver_id'
  has_many :taken_bones, class_name: 'Bone', foreign_key: 'taker_id'

  before_save do
    self.tasks do |task|
      unless task.pending_for? self
        task.notify_ends_today_for(self) if task.ends_today?
      end
    end
  end

	def self.create_with_omniauth auth
		user = User.create!(
			:provider => auth['provider'],
			:uid => auth['uid'],
			:name => auth['info']['name'],
			:email => auth['info']['email']
			)
    
    Contact.where(:email => user.email).each do |contact|
      contact.referenced_user_id = user.id
      contact.save
    end
	end

	def self.authenticate login
		if user = User.find_by_email(login[:email])
			if user.password == login[:password]
				return user
			end
		end
	end

	def owns_task? (task)
		return task.user_id == self.id
	end

  #TODO: find a query for this?
	def is_invited_to_task? task
    task.contacts.each do |c|
      if c.referenced_user_id == self.id
      	return true
      end
    end
    return false
  end

  def invited_tasks
  	return Task.joins(:contacts).where('contacts.referenced_user_id = ?', self.id)
  end

  #TODO: perhaps find another query to avoid uniq! for performance reasons?
  def pending_invited_tasks
  	return self.invited_tasks.joins(:invites).where('invites.pending = ?', true).uniq!
  end

  def active_invited_tasks
    return self.invited_tasks.joins(:invites).where('invites.pending != ? OR invites.pending IS NULL', true).uniq!
  end

  def pending_contacts
  	return self.contacts.where("pending = ?", true)
  end

  def active_contacts
  	return self.contacts.where("pending != ? OR pending IS NULL", true)
  end

  def user_as_contact_for user
  	return self.referenced_contacts.find_by_user_id user.id
  end

  def existing_notification notification
    if notification.contact
      return self.notifications.where(:action => notification.action, :task_id => notification.task.id, :contact_id => notification.contact.id).first
    else
      return self.notifications.where(:action => notification.action, :task_id => notification.task.id).first
    end  
  end
end