class UpdatedVsUnread < ActiveRecord::Migration
  def change
  	rename_column :contacts, :unread, :updated
  	rename_column :tasks, :unread, :updated
  	rename_column :invites, :unread, :updated
  	change_table :tasks do |t|
  		t.boolean :unread
  	end
  	change_table :invites do |t|
  		t.boolean :unread
  	end
  end
end
