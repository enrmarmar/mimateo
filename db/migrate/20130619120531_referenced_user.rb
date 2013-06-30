class ReferencedUser < ActiveRecord::Migration
  def change
  	change_table :contacts do |t|
  		t.integer 'referenced_user_id'
	 	end
  end
end
