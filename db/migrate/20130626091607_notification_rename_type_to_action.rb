class NotificationRenameTypeToAction < ActiveRecord::Migration
  def change
    rename_column :notifications, :type, :action
  end
end
