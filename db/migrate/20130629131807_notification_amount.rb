class NotificationAmount < ActiveRecord::Migration
  def change
    change_table :notifications do |t|
      t.integer :amount
    end
  end
end
