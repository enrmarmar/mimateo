class OmniAuth < ActiveRecord::Migration
  def change
  	change_table "Users" do |t|
  		t.string :provider
  		t.string :uid
  	end
  end
end
