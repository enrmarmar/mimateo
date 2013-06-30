class AddNamesToNotifications < ActiveRecord::Migration
  def change
    change_table :notifications do |t|
      t.string :task_name
      t.string :contact_name
    end
  end
end
