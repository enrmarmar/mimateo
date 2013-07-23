class AddTaskAndContactEmailed < ActiveRecord::Migration
  def change
  	change_table :tasks do |t|
  		t.boolean :emailed
  	end
  	change_table :contacts do |t|
  		t.boolean :emailed
  	end
  end
end
