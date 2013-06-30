class AddTaskCompleted < ActiveRecord::Migration
  def change
  	change_table :tasks do |t|
  		t.boolean 'completed'
  	end
  end
end
