class AddEmailedNotifications < ActiveRecord::Migration
  def change
  	change_table :notifications do |t|
  		t.boolean :emailed
  	end
  end
end
