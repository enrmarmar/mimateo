class AddUserToInvite < ActiveRecord::Migration
  def change
  	change_table :invites do |t|
  		t.belongs_to :user
  	end
  end
end
