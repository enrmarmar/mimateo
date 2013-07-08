class EventModel < ActiveRecord::Migration
  def change
    create_table :google_events do |t|
      t.belongs_to :user
      t.belongs_to :task
      t.string :google_id
      t.timestamps
    end
    remove_column :tasks, :event_id
    remove_column :invites, :event_id
  end
end
