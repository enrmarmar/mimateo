class DeadlineAsDate < ActiveRecord::Migration
  def change
  	remove_column :tasks, :deadline_time
  	remove_column :tasks, :deadline_time
  	change_table :tasks do |t|
  		t.date :deadline
  	end
  end
end
