class FixInvites < ActiveRecord::Migration
  def change
  	add_column :invites, :id, :primary_key
  end
end
