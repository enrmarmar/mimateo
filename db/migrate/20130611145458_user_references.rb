class UserReferences < ActiveRecord::Migration
  def change
  	change_table :tasks do |t|
  		t.references 'user'
  	end

  	change_table :contacts do |t|
  		t.references 'user'
  	end

  end
end
