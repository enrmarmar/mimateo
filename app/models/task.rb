# encoding: UTF-8

class Task < ActiveRecord::Base
	validates :name, :presence=>true
	validate :name_not_too_long?
	belongs_to :user
	has_many :invites, :dependent => :delete_all
	has_many :contacts, :through => :invites, :uniq => true
	has_many :messages, :dependent => :delete_all
	has_many :notifications, :dependent => :delete_all
	has_one :google_event, :dependent => :delete

	before_save do
		self.emailed = not(self.user.receive_emails) if self.user
		true
	end

	after_save do
	    self.notifications.each do |notification|
	      notification.save
	    end
	    self.google_event.save if self.google_event 
	end

	#TODO When in the same week for example return 'friday' instead of date
	def deadline_as_words
		today = Time.now.localtime.to_date
		case self.deadline
		when nil
			'indefinido'
		when today
			'hoy'
		when today + 1
			'mañana'
		else
			self.deadline
		end
	end

	def ends_today?
		self.deadline == Time.now.localtime.to_date
	end

	def deadline_missed?
		if self.deadline
			self.deadline.to_time.to_i < Time.now.localtime.to_i
		else
			false
		end
	end

	def updated_for? user
		if user.owns_task? self
			self.updated
		elsif user.is_invited_to_task? self
			contact = self.user.contacts.find_by_referenced_user_id user.id
			self.invites.find_by_contact_id(contact.id).updated
		end
	end

	def unread_for? user
		if user.owns_task? self
			self.unread
		elsif user.is_invited_to_task? self
			contact = self.user.contacts.find_by_referenced_user_id user.id
			self.invites.find_by_contact_id(contact.id).unread
		end
	end

	def pending_for? user
		user.is_invited_to_task?(self) && self.invites.find_by_contact_id(user.user_as_contact_for self.user).pending
	end

	def syncronized_with_Google_Calendar_for? user
		GoogleEvent.find_by_user_id_and_task_id user.id, self.id
	end

	def mark_as_read_for user
		if user.owns_task? self
			self.updated = false
			self.unread = false
			self.save
		elsif user.is_invited_to_task? self
			contact = user.user_as_contact_for self.user
			contact.updated = false
			invite = self.invites.find_by_contact_id contact.id
			invite.updated = false
			invite.unread = false
			invite.save
		end
		user.notifications.where(
			:task_id => self.id, 
			:action => 'unread_message').destroy_all
	end

	def unmark_as_updated
		self.updated = false
		self.invites.each do |invite|
			invite.updated = false
			invite.save
		end
	end

	def mark_as_updated
		self.updated = true
		self.invites.each do |invite|
			invite.updated = true
			invite.save
			contact = self.user.user_as_contact_for invite.user
			contact.updated = true
			contact.save
		end
	end

	def mark_as_unread
		self.unread = true
		self.save
		self.invites.each do |invite|
			invite.unread = true
			invite.save
		end
	end

	def mark_as_pending_for user
		contact = user.user_as_contact_for self.user
		invite = self.invites.find_by_contact_id contact
		invite.pending = true
		invite.save
	end

	def mark_as_completed
		self.completed = true
    self.save
    self.mark_as_updated
    self.notify_completed
    self.clear_notify_date
    self.google_event.destroy if self.google_event
	end

	def unmark_as_pending_for user
		contact = user.user_as_contact_for self.user
		invite = self.invites.find_by_contact_id contact
		invite.pending = false
		invite.save
	end

	def destroy_invitation_for user
		contact = user.user_as_contact_for self.user
		if invite = self.invites.find_by_contact_id(contact)
			invite.destroy
			user.notifications.where(:task_id => self.id).destroy_all
			self.notify_refused_by user
		end
	end

	def notify_refused_by user
		notification = Notification.create!(
			:action => 'refused_task',
			:user => self.user,
			:contact => user.user_as_contact_for(self.user),
			:task => self)
	end

	def notify_accepted_by user
		notification = Notification.create!(
			:action => 'accepted_task',
			:user => self.user,
			:contact => user.user_as_contact_for(self.user),
			:task => self)
	end

	def update_notify_date_for user
		previous_notify_ends_today = user.notifications.where(
			:task_id => self.id,
			:action => 'ends_today_task').first
		previous_notify_deadline_missed = user.notifications.where(
			:task_id => self.id,
			:action => 'deadline_missed_task').first
		if self.ends_today?
			unless previous_notify_ends_today
				notification = Notification.create!(
	      	:action => 'ends_today_task',
	      	:user => user,
	      	:task => self)
	    end
	  elsif self.deadline_missed?
	  	previous_notify_ends_today.destroy if previous_notify_ends_today
	  	unless previous_notify_deadline_missed
	  		notification = Notification.create!(
	      	:action => 'deadline_missed_task',
	      	:user => user,
	      	:task => self)
	  	end
    end
	end

	def clear_notify_date
		self.notifications.where(:action => 'ends_today_task').destroy_all
    self.notifications.where(:action => 'deadline_missed_task').destroy_all
	end

	%w(updated completed deleted postponed).each do |action|
		define_method "notify_#{action}" do
			self.contacts.each do |contact|
				unless self.pending_for? contact.referenced_user
					notification = Notification.create!(
			      :action => action + '_task',
			      :user => contact.referenced_user,
			      :contact => self.user.user_as_contact_for(contact.referenced_user),
			      :task => self)
		    end
			end
		end
	end

	private
	# Custom validator

  def name_not_too_long?
  	if self.name
    	errors.add(:base, "Nombre demasiado largo, máximo 30 caracteres") if self.name.length > 30
  	end
  end

end