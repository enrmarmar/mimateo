class CreateUserAndTaskTables < ActiveRecord::Migration
  def up
    create_table 'users' do |t|
      t.string 'name'
      t.string 'password'
      t.string 'email'
      t.timestamp
    end
    
    create_table 'tasks' do |t|
      t.string 'name'
      t.text 'description'
      t.datetime 'deadline'
    end
  end

  def down
  end
end
