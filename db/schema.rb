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

ActiveRecord::Schema.define(version: 20150102194550) do

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

end
