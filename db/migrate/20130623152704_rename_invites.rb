class RenameInvites < ActiveRecord::Migration
  def change
  	rename_table :contacts_tasks, :invites
  end
end
