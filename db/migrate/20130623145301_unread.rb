class Unread < ActiveRecord::Migration
  def change
  	change_table :tasks do |t|
  		t.boolean 'unread'
  	end

  	change_table :contacts do |t|
  		t.boolean 'unread'
  	end
  end
end
