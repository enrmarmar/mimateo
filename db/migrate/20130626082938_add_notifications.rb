class AddNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string :type
    end
  end
end
