class Bones < ActiveRecord::Migration
  def change
    create_table :bones do |t|
      t.belongs_to :giver, class_name: 'user'
      t.belongs_to :taker, class_name: 'user'
      t.belongs_to :task
      t.string :task_name
      t.integer :amount
      t.timestamps
    end
  end
end
