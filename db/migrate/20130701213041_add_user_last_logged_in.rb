class AddUserLastLoggedIn < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.datetime :last_logged_in
    end
  end
end
