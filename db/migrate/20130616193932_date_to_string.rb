class DateToString < ActiveRecord::Migration
  def change
  	change_table :tasks do |t|
  		t.string 'deadline_time'
  		t.string 'deadline_date'
  	end
  	remove_column :tasks, 'deadline'
  end

end
