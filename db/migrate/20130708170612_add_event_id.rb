class AddEventId < ActiveRecord::Migration
  def change
    change_table :tasks do |t|
      t.string :event_id
    end
    change_table :invites do |t|
      t.string :event_id
    end
  end
end
