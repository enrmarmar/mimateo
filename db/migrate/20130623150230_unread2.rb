class Unread2 < ActiveRecord::Migration
  def change
  	change_table :contacts_tasks do |t|
  		t.boolean 'unread'
  	end
	end
end
