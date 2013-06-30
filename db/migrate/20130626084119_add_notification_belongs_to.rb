class AddNotificationBelongsTo < ActiveRecord::Migration
  def change
    change_table :notifications do |t|
      t.belongs_to :user
      t.belongs_to :contact
      t.belongs_to :task
    end
  end
end
