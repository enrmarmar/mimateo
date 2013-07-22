# encoding: UTF-8

class Contact < ActiveRecord::Base
	belongs_to :user
	has_many :invites
	has_many :tasks, :through => :invites, :uniq => true
	has_many :notifications
	belongs_to :referenced_user, :class_name => "User"
	
  validates :name, :presence=>true
  validates :email, :presence=>true
  validates :email,
  :format => { :with => /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/,
    :message => ": dirección email incorrecta" }
  validate :unique_name?
  validate :unique_email?
  validate :not_himself?
  validate :name_not_too_long?

  before_save do
		if referenced_user = User.find_by_email(self.email)
			self.referenced_user = referenced_user
		end
	end

  after_save do
    self.notifications.each do |notification|
      notification.save
    end
  end

  after_destroy do
    if affected_user = self.referenced_user
      # We delete invitations both ways
      affected_user.tasks.each do |task|
        task.destroy_invitation_for self.user
      end
      self.user.tasks.each do |task|
        task.destroy_invitation_for affected_user
      end
      # We delete notifications both ways
      self.user.notifications.where(
        :contact_id => self.id).destroy_all
      if affected_contact = self.user.user_as_contact_for(affected_user)
        affected_user.notifications.where(
          :contact_id => affected_contact.id).destroy_all
      end
      self.notify_deleted
    end
  end

  def active?
    return false unless self.referenced_user
    self.referenced_user.contacts.find_by_email self.user.email
  end

	def notify_deleted
    # in case A deletes contact B and, in revenge, B deletes contact A... A shouldn't get an empty notification 
    if referenced_contact = self.referenced_user.contacts
      .find_by_referenced_user_id(self.user.id)
		notification = Notification.create!(
      :action => 'deleted_contact',
      :user => self.referenced_user,
      :contact => referenced_contact)
    end
	end

  # Custom validators
  private


  def unique_name?
    other_contact = self.user.contacts.find_by_name(self.name)
    if other_contact && (other_contact != self)
      errors.add(:base, "Ya tienes otro contacto con el mismo nombre")
    end
  end

  def unique_email?
    other_contact = self.user.contacts.find_by_email(self.email)
    if other_contact && (other_contact != self)
      errors.add(:base, "Ya tienes otro contacto con el mismo email")
    end
  end

  def not_himself?
    errors.add(:base, "No te puedes agregar a ti mismo como contacto") if self.email == self.user.email
  end

  def name_not_too_long?
    errors.add(:base, "Nombre demasiado largo, máximo 30 caracteres") if self.name.length > 30
  end

end