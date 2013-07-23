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

    #Default user configuration
    if self.has_google_account?
      self.receive_emails = true
      self.auto_synchronize_with_GoogleCalendar = true
    else
      self.receive_emails = false
      self.auto_synchronize_with_GoogleCalendar = false
    end
    true
  end

	def self.create_with_omniauth auth
		user = User.create!(
			:provider => auth['provider'],
			:uid => auth['uid'],
			:name => auth['info']['name'],
			:email => auth['info']['email']
			)
    UserMailer.welcome_email(user).deliver
    user
  end

	def self.authenticate login
		if user = User.find_by_email(login[:email])
			if user.password == login[:password]
				return user
			end
		end
	end

  def has_google_account?
    false unless self.uid
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
  	self.invited_tasks.joins(:invites).where('invites.pending = ?', true).uniq!
  end

  def active_invited_tasks
    #TODO Figure out why do I need uniq! here
    self.invited_tasks.joins(:invites).where('invites.pending = ?', false).uniq!
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

  def unmailed_pending_contacts
    self.pending_contacts.where(:emailed => false)
  end

  def unmailed_pending_invited_tasks
    self.pending_invited_tasks.where(:emailed => false)
  end

  def unmailed_notifications
    self.notifications.where(:emailed => false)
  end

  def unmailed_updates?
    not(unmailed_pending_contacts.empty?) ||
    not(unmailed_pending_invited_tasks.empty?) ||
    not(unmailed_notifications.empty?)
  end

  def check_updates_as_mailed
    unmailed_pending_contacts.update_all :emailed => true
    unmailed_pending_invited_tasks.update_all :emailed => true
    unmailed_notifications.update_all :emailed => true
  end

  def mail_updates
    if self.unmailed_updates?
      UserMailer.update_email(self).deliver
      check_updates_as_mailed
    end
  end

end