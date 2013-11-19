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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20131116004239) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "departments", force: true do |t|
    t.string   "name"
    t.integer  "manager_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "task_actions", force: true do |t|
    t.string   "name"
    t.integer  "task_project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "task_customers", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "task_details", force: true do |t|
    t.string   "name"
    t.integer  "task_action_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "task_projects", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "task_slots", force: true do |t|
    t.integer  "task_id"
    t.datetime "start_time"
    t.datetime "stop_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "task_statuses", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "task_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tasks", force: true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.integer  "task_type_id"
    t.integer  "task_customer_id"
    t.integer  "task_project_id"
    t.integer  "task_action_id"
    t.integer  "task_detail_id"
    t.integer  "task_status_id"
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "time_request_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "time_requests", force: true do |t|
    t.string   "name"
    t.string   "comment"
    t.integer  "time_request_type_id"
    t.integer  "user_id"
    t.datetime "from"
    t.datetime "to"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "username",                        null: false
    t.string   "email"
    t.string   "crypted_password"
    t.string   "salt"
    t.integer  "role_id"
    t.integer  "department_id"
    t.integer  "yearly_pto_hour_allotment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "reset_password_token"
    t.datetime "reset_password_token_expires_at"
    t.datetime "reset_password_email_sent_at"
  end

  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", using: :btree

end
