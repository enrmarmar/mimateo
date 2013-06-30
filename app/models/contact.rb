class Contact < ActiveRecord::Base
	validates :name, :presence=>true
	validates :email, :presence=>true
	validates :email,
	:format => { :with => /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/, :message => ": Direccion email incorrecta" }
	# TODO: Prevent user from adding himself as a contact
	# TODO: Validate email uniqueness on user_id scope
	belongs_to :user
	# TODO: Change foreign key name to owner_user_id
	has_many :invites
	has_many :tasks, :through => :invites, :uniq => true
	has_many :notifications
	belongs_to :referenced_user, :class_name => "User"
	before_save do
		if referenced_user = User.find_by_email(self.email)
			self.referenced_user = referenced_user
		end
	end

	def notify_deleted
		notification = Notification.new
    notification.action = 'deleted_contact'
    notification.user = self.referenced_user
    referenced_contact = self.referenced_user.contacts.find_by_referenced_user_id self.user.id
    notification.contact = referenced_contact
    notification.save if referenced_contact
    # in case A deletes contact B and, in revenge, B deletes contact A... A shouldn't get an empty notification 
	end

end