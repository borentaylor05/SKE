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

ActiveRecord::Schema.define(version: 20150120174332) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "clients", force: true do |t|
    t.string   "name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "kb_space_id"
    t.string   "kb_url"
  end

  create_table "content_requests", force: true do |t|
    t.string   "request_type"
    t.integer  "content_id"
    t.string   "title"
    t.string   "description"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "client_id"
  end

  create_table "contents", force: true do |t|
    t.integer  "api_id"
    t.string   "doc_id"
    t.string   "title"
    t.integer  "user_id"
    t.integer  "client_id"
    t.boolean  "featured"
    t.string   "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "cType"
  end

  create_table "contents_specialties", id: false, force: true do |t|
    t.integer "content_id",   null: false
    t.integer "specialty_id", null: false
  end

  add_index "contents_specialties", ["content_id", "specialty_id"], name: "index_contents_specialties_on_content_id_and_specialty_id", using: :btree
  add_index "contents_specialties", ["specialty_id", "content_id"], name: "index_contents_specialties_on_specialty_id_and_content_id", using: :btree

  create_table "issues", force: true do |t|
    t.string   "summary"
    t.integer  "created_by"
    t.integer  "content_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.boolean  "resolved"
    t.integer  "resolved_by"
    t.datetime "resolved_at"
    t.integer  "api_id"
    t.string   "issue_type"
    t.string   "url"
    t.string   "title"
  end

  create_table "old_comments", force: true do |t|
    t.integer  "old_content_id"
    t.integer  "api_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.boolean  "resolved"
    t.datetime "resolved_at"
  end

  add_index "old_comments", ["api_id"], name: "index_old_comments_on_api_id", using: :btree

  create_table "old_contents", force: true do |t|
    t.integer  "api_id"
    t.integer  "comments"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "link"
    t.string   "commentsUrl"
    t.string   "title"
  end

  add_index "old_contents", ["api_id"], name: "index_old_contents_on_api_id", using: :btree

  create_table "posts", force: true do |t|
    t.integer  "user_id"
    t.integer  "client_id"
    t.string   "action_type"
    t.integer  "action_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "specialties", force: true do |t|
    t.string   "name"
    t.integer  "client_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "specialties", ["name"], name: "index_specialties_on_name", using: :btree

  create_table "specialties_users", id: false, force: true do |t|
    t.integer "user_id",      null: false
    t.integer "specialty_id", null: false
  end

  add_index "specialties_users", ["specialty_id", "user_id"], name: "index_specialties_users_on_specialty_id_and_user_id", using: :btree
  add_index "specialties_users", ["user_id", "specialty_id"], name: "index_specialties_users_on_user_id_and_specialty_id", using: :btree

  create_table "updates", force: true do |t|
    t.string   "text"
    t.integer  "user_id"
    t.integer  "client_id"
    t.string   "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: true do |t|
    t.integer  "jive_id"
    t.string   "employee_id"
    t.integer  "client_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "password"
    t.string   "name"
  end

  create_table "ww_code_infos", force: true do |t|
    t.string   "agent_id"
    t.string   "agent_name"
    t.integer  "sub_num"
    t.string   "member_first_name"
    t.string   "member_last_name"
    t.integer  "member_zip"
    t.integer  "ww_code_id"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "token"
    t.text     "description"
    t.string   "requesting_type"
    t.boolean  "used",              default: false
    t.string   "reviewed_by"
  end

  add_index "ww_code_infos", ["agent_name"], name: "index_ww_code_infos_on_agent_name", using: :btree
  add_index "ww_code_infos", ["token"], name: "index_ww_code_infos_on_token", unique: true, using: :btree

  create_table "ww_codes", force: true do |t|
    t.string   "code_type"
    t.string   "code_num"
    t.datetime "date_assigned"
    t.string   "assigned_by"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.boolean  "used",             default: false
    t.string   "assigned_by_name"
  end

  add_index "ww_codes", ["assigned_by_name"], name: "index_ww_codes_on_assigned_by_name", using: :btree
  add_index "ww_codes", ["code_num"], name: "index_ww_codes_on_code_num", using: :btree

end
