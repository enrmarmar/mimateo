class Task < ActiveRecord::Base
	validates :name, :presence=>true
	belongs_to :user
	has_many :invites, :dependent => :delete_all
	has_many :contacts, :through => :invites, :uniq => true
	has_many :messages, :dependent => :delete_all
	has_many :notifications, :dependent => :delete_all

	def updated_for? user
		if user.owns_task? self
			return self.updated
		elsif user.is_invited_to_task? self
			contact = self.user.contacts.find_by_referenced_user_id user.id
			return self.invites.find_by_contact_id(contact.id).updated
		end
	end

	def unread_for? user
		if user.owns_task? self
			return self.unread
		elsif user.is_invited_to_task? self
			contact = self.user.contacts.find_by_referenced_user_id user.id
			return self.invites.find_by_contact_id(contact.id).unread
		end
	end

	def pending_for? user
		return user.is_invited_to_task?(self) && self.invites.find_by_contact_id(user.user_as_contact_for self.user).pending
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
	end

	def notify_completed
		self.contacts.each do |contact|
			unless self.pending_for? contact.referenced_user
				notification = Notification.new
	      notification.action = 'completed_task'
	      notification.user = contact.referenced_user
	      notification.contact = self.user.user_as_contact_for contact.referenced_user
	      notification.task = self
	      notification.save
	    end
		end
	end

	def notify_updated
		self.contacts.each do |contact|
			unless self.pending_for? contact.referenced_user
				notification = Notification.new
	      notification.action = 'updated_task'
	      notification.user = contact.referenced_user
	      notification.contact = self.user.user_as_contact_for contact.referenced_user
	      notification.task = self
	      notification.save
	    end
		end
	end

	def notify_postponed
		self.contacts.each do |contact|
			unless self.pending_for? contact.referenced_user
				notification = Notification.new
	      notification.action = 'postponed_task'
	      notification.user = contact.referenced_user
	      notification.contact = self.user.user_as_contact_for contact.referenced_user
	      notification.task = self
	      notification.save
	    end
		end
	end

	def notify_deleted
		self.contacts.each do |contact|
			unless self.pending_for? contact.referenced_user
				notification = Notification.new
	      notification.action = 'deleted_task'
	      notification.user = contact.referenced_user
	      notification.contact = self.user.user_as_contact_for contact.referenced_user
	      notification.task = self
	      notification.save
	    end
		end
	end

end
