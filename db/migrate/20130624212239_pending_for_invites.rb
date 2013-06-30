class PendingForInvites < ActiveRecord::Migration
  def change
    remove_column :tasks, :pending
    change_table :invites do |t|
      t.boolean :pending
    end
  end
end
