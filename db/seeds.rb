# encoding: UTF-8

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Test users
ana = User.create(name: 'Ana', email: 'ana@prueba.es')
pedro = User.create(name: 'Pedro', email: 'pedro@prueba.es')
ramon = User.create(name: 'Ramón', email: 'ramon@prueba.es')
isabel = User.create(name: 'Isabel', email: 'isabel@prueba.es')

#Test contacts
a_p = Contact.create(name: ana.name, email: ana.email, referenced_user_id: ana.id, user_id: pedro.id)
a_r = Contact.create(name: ana.name, email: ana.email, referenced_user_id: ana.id, user_id: ramon.id)
a_i = Contact.create(name: ana.name, email: ana.email, referenced_user_id: ana.id, user_id: isabel.id)
p_a = Contact.create(name: pedro.name, email: pedro.email, referenced_user_id: pedro.id, user_id: ana.id)
p_r = Contact.create(name: pedro.name, email: pedro.email, referenced_user_id: pedro.id, user_id: ramon.id)
p_i = Contact.create(name: pedro.name, email: pedro.email, referenced_user_id: pedro.id, user_id: isabel.id)
r_a = Contact.create(name: ramon.name, email: ramon.email, referenced_user_id: ramon.id, user_id: ana.id)
r_p = Contact.create(name: ramon.name, email: ramon.email, referenced_user_id: ramon.id, user_id: pedro.id)
r_i = Contact.create(name: ramon.name, email: ramon.email, referenced_user_id: ramon.id, user_id: isabel.id)
i_a = Contact.create(name: isabel.name, email: isabel.email, referenced_user_id: isabel.id, user_id: ana.id)
i_p = Contact.create(name: isabel.name, email: isabel.email, referenced_user_id: isabel.id, user_id: pedro.id)
i_r = Contact.create(name: isabel.name, email: isabel.email, referenced_user_id: isabel.id, user_id: ramon.id)
Contact.update_all :pending => false

#Test tasks
t1 = Task.create(name: 'Comprar detergente', user_id: ana.id)
t2 = Task.create(name: 'Pasar la aspiradora', user_id: ana.id)
t3 = Task.create(name: 'Estudiar ruso', user_id: ana.id)
t4 = Task.create(name: 'Podar el jardín', user_id: pedro.id)
t5 = Task.create(name: 'Llevar coche al taller', user_id: pedro.id)
t6 = Task.create(name: 'Vacunar al perro', user_id: ramon.id)

#Test invites
Invite.create(task_id: t1.id, contact_id: p_a.id)
Invite.create(task_id: t1.id, contact_id: r_a.id)
Invite.create(task_id: t1.id, contact_id: i_a.id)
Invite.create(task_id: t3.id, contact_id: p_a.id)
Invite.create(task_id: t4.id, contact_id: a_p.id)
Invite.create(task_id: t4.id, contact_id: r_p.id)
Invite.create(task_id: t4.id, contact_id: i_p.id)
Invite.create(task_id: t6.id, contact_id: p_r.id)
Invite.update_all :pending => false

#Test messages
Message.create(task_id: t1.id, user_id: ana.id, text: 'A ver si alguien me ayuda a comprar detergente')
Message.create(task_id: t1.id, user_id: pedro.id, text: 'Tienen una oferta muy buena en el Carrefour')
Message.create(task_id: t1.id, user_id: ramon.id, text: 'Yo le tengo fobia a los supermercados, no cuentes conmigo')
Message.create(task_id: t1.id, user_id: isabel.id, text: 'A mí me sobra una caja de una oferta 3x2, a lo mejor te sirve...')
