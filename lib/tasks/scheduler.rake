desc "This task is called by the Heroku scheduler add-on"
task :update_feed => :environment do
  puts "Sending update emails..."
  i = 0
  User.all.each do |user|
  	user.mail_updates if user.receive_emails
  	i++
  end
  puts "Sending update emails(" + i +") done."
end