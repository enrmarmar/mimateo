class Messages < ActiveRecord::Migration
  def change
  	create_table 'messages' do |t|
  		t.text 'text'
  		t.integer 'task_id'
  		t.integer 'user_id'
  		t.timestamp
  	end
  end
end
