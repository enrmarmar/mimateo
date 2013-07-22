class User < ActiveRecord::Base
	validates :email, :uniqueness=>true
	validates :email, :format => { :with => /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/, :message => ": Direccion email incorrecta" }
  
	has_many :tasks, :dependent => :delete_all
	has_many :contacts, :dependent => :delete_all
	has_many :referenced_contacts, :class_name => "Contact", :foreign_key => "referenced_user_id"
	has_many :messages
  has_many :notifications, :dependent => :delete_all
  has_many :given_bones, class_name: 'Bone', foreign_key: 'giver_id'
  has_many :taken_bones, class_name: 'Bone', foreign_key: 'taker_id'
  has_many :google_events, :dependent => :delete_all

  before_save do
    self.active_tasks.each do |task|
      unless task.pending_for? self
        task.update_notify_date_for self
      end
    end
    self.contacts.each do |contact|
      contact.referenced_user_id = self.id
      contact.save
    end
  end

	def self.create_with_omniauth auth
		user = User.create!(
			:provider => auth['provider'],
			:uid => auth['uid'],
			:name => auth['info']['name'],
			:email => auth['info']['email']
			)
    UserMailer.welcome_email(user).deliver
	end

	def self.authenticate login
		if user = User.find_by_email(login[:email])
			if user.password == login[:password]
				return user
			end
		end
	end

  def has_google_account?
    true unless self.uid == nil
  end

	def owns_task? task
		task.user_id == self.id
	end

  #TODO: find a query for this?
	def is_invited_to_task? task
    task.contacts.each do |c|
      if c.referenced_user_id == self.id
      	return true
      end
    end
    false
  end

  def invited_tasks
  	Task.joins(:contacts).where('contacts.referenced_user_id = ?', self.id)
  end

  def active_tasks
    self.tasks + self.active_invited_tasks.to_a
  end

  def pending_invited_tasks
  	self.invited_tasks.joins(:invites).where('invites.pending = ?', true)
  end

  #TODO: perhaps find another query to avoid uniq! for performance reasons?
  def active_invited_tasks
    self.invited_tasks.joins(:invites).where('invites.pending != ? OR invites.pending IS NULL', true).uniq!
  end

  def pending_contacts
  	self.contacts.where("pending = ?", true)
  end

  def active_contacts
  	self.contacts.where("pending != ? OR pending IS NULL", true)
  end

  def user_as_contact_for user
  	self.referenced_contacts.find_by_user_id user.id
  end

  def name_for user
    return nil unless contact = self.user_as_contact_for(user)
    contact.name
  end

  def existing_notification notification
    if notification.contact
      self.notifications.where(
        :action => notification.action,
        :task_id => notification.task.id,
        :contact_id => notification.contact.id).first
    else
      self.notifications.where(
        :action => notification.action,
        :task_id => notification.task.id).first
    end  
  end
end