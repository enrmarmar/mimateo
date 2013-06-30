class Timestamps < ActiveRecord::Migration
  def change
  	change_table :users do |t|
  		t.timestamps
  	end

  	change_table :tasks do |t|
  		t.timestamps
  	end

  	change_table :contacts do |t|
  		t.timestamps
  	end

  	change_table :contacts_tasks do |t|
  		t.timestamps
  	end

  	change_table :messages do |t|
  		t.timestamps
  	end
	end
end
