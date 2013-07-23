class UserMailer < ActionMailer::Base
  default from: "Mi Mateo WebApp" 'app16629786@heroku.com'
 
  def welcome_email user
    @user = user
    @url  = 'http://cryptic-fjord-9664.herokuapp.com/index'
    mail(to: @user.email, subject: 'Bienvenido/a a Mi Mateo, el organizador social de tareas')
  end

  def invite_email (contact, inviter_user)
  	@contact = contact
  	@inviter_user = inviter_user
    @url  = 'http://cryptic-fjord-9664.herokuapp.com/index'
    mail(to: @contact.email, subject: 'Te han invitado a utilizar Mi Mateo, el organizador social de tareas')
  end
end