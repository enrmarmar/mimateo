class Pending < ActiveRecord::Migration
  def change
  	change_table :tasks do |t|
  		t.boolean :pending
  	end

		change_table :contacts do |t|
  		t.boolean :pending
  	end

  end
end
