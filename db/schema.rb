# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130723020029) do

  create_table "bones", :force => true do |t|
    t.integer  "giver_id"
    t.integer  "taker_id"
    t.integer  "task_id"
    t.string   "task_name"
    t.integer  "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contacts", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.integer  "user_id"
    t.integer  "referenced_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "updated"
    t.boolean  "pending"
    t.boolean  "emailed"
  end

  create_table "google_events", :force => true do |t|
    t.integer  "user_id"
    t.integer  "task_id"
    t.string   "google_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invites", :force => true do |t|
    t.integer  "contact_id"
    t.integer  "task_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "updated"
    t.boolean  "unread"
    t.boolean  "pending"
  end

  create_table "messages", :force => true do |t|
    t.text     "text"
    t.integer  "task_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notifications", :force => true do |t|
    t.string   "action"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "contact_id"
    t.integer  "task_id"
    t.string   "task_name"
    t.string   "contact_name"
    t.integer  "amount"
    t.boolean  "emailed"
  end

  create_table "tasks", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "user_id"
    t.boolean  "completed"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "updated"
    t.boolean  "unread"
    t.date     "deadline"
    t.boolean  "emailed"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "password"
    t.string   "email"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_logged_in"
    t.string   "token"
    t.string   "refresh_token"
    t.datetime "token_expires_at"
    t.boolean  "receive_emails"
    t.boolean  "auto_synchronize_with_GoogleCalendar"
  end

end
