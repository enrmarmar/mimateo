class RemoveDeadlineDate < ActiveRecord::Migration
  def change
  	remove_column :tasks, :deadline_date
  end
end
