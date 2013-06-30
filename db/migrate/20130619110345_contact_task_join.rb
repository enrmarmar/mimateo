class ContactTaskJoin < ActiveRecord::Migration
  def change
  	create_table :contacts_tasks, :id => false do |t|
      t.integer :contact_id
      t.integer :task_id
    end
  end
end
