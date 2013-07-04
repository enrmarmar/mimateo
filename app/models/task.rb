# encoding: UTF-8

class Task < ActiveRecord::Base
	validates :name, :presence=>true
	belongs_to :user
	has_many :invites, :dependent => :delete_all
	has_many :contacts, :through => :invites, :uniq => true
	has_many :messages, :dependent => :delete_all
	has_many :notifications, :dependent => :delete_all

	#TODO When in the same week for example return 'friday' instead of date
	def deadline_as_words
		today = Time.now.localtime.to_date
		case self.deadline
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

	def mark_as_read_for user
		if user.owns_task? self
			self.updated = false
			self.unread = false
			self.save
		elsif user.is_invited_to_task? self
			contact = user.user_as_contact_for self.user
			invite = self.invites.find_by_contact_id contact.id
			invite.updated = false
			invite.unread = false
			invite.save
		end
		user.notifications.where(:task_id => self.id, :action => 'unread_message').destroy_all
	end

	def mark_as_updated
		self.updated = true
		self.save
		self.invites.each do |invite|
			invite.updated = true
			invite.save
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

	def unmark_as_pending_for user
		contact = user.user_as_contact_for self.user
		invite = self.invites.find_by_contact_id contact
		invite.pending = false
		invite.save
	end

	def destroy_invitation_for user
		contact = user.user_as_contact_for self.user
		invite = self.invites.find_by_contact_id contact
		invite.destroy
		user.notifications.where(:task_id => self.id).destroy_all
		self.notify_refused_by user
	end

	def notify_refused_by user
		notification = Notification.new
		notification.action = 'refused_task'
		notification.user = self.user
		notification.contact = user.user_as_contact_for self.user
		notification.task = self
		notification.save
	end

	def notify_accepted_by user
		notification = Notification.new
		notification.action = 'accepted_task'
		notification.user = self.user
		notification.contact = user.user_as_contact_for self.user
		notification.task = self
		notification.save
	end

	def update_notify_date_for user
		previous_notify_ends_today = user.notifications.where(:task_id => self.id, :action => 'ends_today_task').first
		previous_notify_deadline_missed = user.notifications.where(:task_id => self.id, :action => 'deadline_missed_task').first
		if self.ends_today?
			unless previous_notify_ends_today
				notification = Notification.new
	      notification.action = 'ends_today_task'
	      notification.user = user
	      notification.task = self
	      notification.save
	    end
	  elsif self.deadline_missed?
	  	previous_notify_ends_today.destroy if previous_notify_ends_today
	  	unless previous_notify_deadline_missed
	  		notification = Notification.new
	      notification.action = 'deadline_missed_task'
	      notification.user = user
	      notification.task = self
	      notification.save
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
					notification = Notification.new
		      notification.action = action + '_task'
		      notification.user = contact.referenced_user
		      notification.contact = self.user.user_as_contact_for contact.referenced_user
		      notification.task = self
		      notification.save
		    end
			end
		end
	end

end
