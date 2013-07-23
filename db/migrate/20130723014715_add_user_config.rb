class AddUserConfig < ActiveRecord::Migration
  def change
  	change_table :users do |t|
  		t.boolean :receive_emails
  		t.boolean :auto_synchronize_with_GoogleCalendar
  	end
  end
end
