class Contact < ActiveRecord::Base
	belongs_to :user
	has_many :invites
	has_many :tasks, :through => :invites, :uniq => true
	has_many :notifications
	belongs_to :referenced_user, :class_name => "User"
	
  validates :name, :presence=>true
  validates :email, :presence=>true
  validates :email,
  :format => { :with => /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/, :message => ": direccion email incorrecta" }
  validate :unique_name?
  validate :unique_email?
  validate :not_himself?

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

  private

  def unique_name?
    errors.add(:base, "Ya tienes otro contacto con el mismo nombre") if self.user.contacts.find_by_name(self.name)
  end

  def unique_email?
    errors.add(:base, "Ya tienes otro contacto con el mismo email") if self.user.contacts.find_by_email(self.email)
  end

  def not_himself?
    errors.add(:base, "No te puedes agregar a ti mismo como contacto") if self.email == self.user.email
  end

end