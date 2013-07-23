desc "This task is called by the Heroku scheduler add-on"
task :update_feed => :environment do
  puts "Sending update emails..."
  i = 0
  User.all.each do |user|
  	user.mail_updates and i+= 1 if user.receive_emails
  end
  puts "Emails sent: " + i.to_s
  puts "Sending update emails done."
end