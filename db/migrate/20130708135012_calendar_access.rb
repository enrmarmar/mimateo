class CalendarAccess < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string :token 
      t.string :refresh_token
      t.datetime :token_expires_at
    end
  end
end
