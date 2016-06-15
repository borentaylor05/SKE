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

ActiveRecord::Schema.define(version: 20160615205217) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "a_to_z_entries", force: true do |t|
    t.string   "topic"
    t.string   "aka"
    t.string   "owner"
    t.string   "scope"
    t.string   "notes"
    t.string   "program_flow"
    t.string   "cdc_link"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.boolean  "pr"
    t.boolean  "spanish"
  end

  create_table "address_book_entries", force: true do |t|
    t.string   "ProgramDescription"
    t.string   "AlternateTopicName"
    t.string   "Owner"
    t.string   "LastName"
    t.string   "FirstName"
    t.string   "EmailAddress"
    t.string   "WorkPhone"
    t.string   "CommentText"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "adds", force: true do |t|
    t.string   "Suburb"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admins", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "client_id"
    t.boolean  "administrator",          default: false
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree

  create_table "arc_blackout_dates", force: true do |t|
    t.string   "date"
    t.string   "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date     "expires"
    t.string   "date_type"
  end

  create_table "arc_blackout_trackers", force: true do |t|
    t.integer  "arc_blackout_date_id"
    t.integer  "arc_city_state_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "arc_check_trackers", force: true do |t|
    t.string   "check_num"
    t.decimal  "check_amount", precision: 10, scale: 2
    t.string   "check_date"
    t.string   "org"
    t.string   "check_name"
    t.string   "state"
    t.string   "tsc_received"
    t.string   "order_num"
    t.string   "crs"
    t.string   "notes"
    t.string   "sent_back_by"
    t.string   "agent_name"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "case_id"
  end

  add_index "arc_check_trackers", ["check_num"], name: "index_arc_check_trackers_on_check_num", using: :btree

  create_table "arc_city_state_groups", force: true do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "state_id"
  end

  create_table "arc_city_states", force: true do |t|
    t.string   "city"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "state_id"
  end

  create_table "arc_group_trackers", force: true do |t|
    t.integer  "arc_city_state_id"
    t.integer  "arc_city_state_group_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "article_requests", force: true do |t|
    t.string   "title"
    t.text     "summary"
    t.string   "file_label"
    t.string   "file_url"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "file_label2"
    t.string   "file_label3"
    t.string   "file_url2"
    t.string   "file_url3"
    t.string   "lob"
    t.datetime "pub_date"
    t.datetime "expire_date"
    t.integer  "priority"
    t.string   "request_type"
  end

  create_table "cdc_apg_documents", force: true do |t|
    t.integer  "client_id"
    t.string   "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "url"
  end

  create_table "cdc_apg_notes", force: true do |t|
    t.integer  "cdc_apg_subheader_id"
    t.text     "text"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "cdc_apg_paragraphs", force: true do |t|
    t.integer  "cdc_apg_subheader_id"
    t.text     "text"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "cdc_apg_sections", force: true do |t|
    t.string   "title"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "cdc_apg_document_id"
  end

  create_table "cdc_apg_subheaders", force: true do |t|
    t.string   "title"
    t.integer  "cdc_apg_section_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "clients", force: true do |t|
    t.string   "name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "kb_space_id"
    t.string   "kb_url"
  end

  create_table "comment_issues", force: true do |t|
    t.integer  "old_comment_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
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

  create_table "cost_per_thousands", force: true do |t|
    t.string   "publications"
    t.integer  "cost"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "cost_per_thousands_fx_publications", force: true do |t|
    t.integer  "cost_per_thousand_id"
    t.integer  "fx_publication_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "deadlines", force: true do |t|
    t.string   "publication"
    t.string   "nz_time"
    t.string   "mla_time"
    t.string   "run_day"
    t.string   "close_day"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "deadlines", ["publication"], name: "index_deadlines_on_publication", using: :btree

  create_table "empower_missions", force: true do |t|
    t.string   "metric_name"
    t.string   "target"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "units"
  end

  create_table "fx_class_cats", force: true do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fx_classifications", force: true do |t|
    t.string   "title"
    t.string   "code"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "fx_class_cat_id"
  end

  create_table "fx_code_rates", force: true do |t|
    t.string   "schedule"
    t.string   "month_code"
    t.decimal  "month_rate"
    t.string   "year_code"
    t.decimal  "year_rate"
    t.string   "other"
    t.boolean  "three_day"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "fx_publication_id"
  end

  create_table "fx_mag_pricings", force: true do |t|
    t.string   "six_month"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "fx_publication_id"
    t.string   "pay_type"
    t.decimal  "one_year"
    t.decimal  "one_year_aus"
    t.decimal  "one_year_row"
    t.decimal  "two_years"
    t.decimal  "three_years"
    t.decimal  "bank"
    t.decimal  "credit"
  end

  create_table "fx_news_agents", force: true do |t|
    t.string   "code"
    t.string   "agent"
    t.string   "fax_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "fx_news_agents", ["code"], name: "index_fx_news_agents_on_code", using: :btree

  create_table "fx_publications", force: true do |t|
    t.string   "name"
    t.string   "parent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean  "mag"
    t.boolean  "se"
    t.boolean  "has_se"
  end

  add_index "fx_publications", ["name"], name: "index_fx_publications_on_name", using: :btree

  create_table "fx_publications_suburbs", force: true do |t|
    t.integer  "fx_publication_id"
    t.integer  "suburb_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "fx_se_pricings", force: true do |t|
    t.integer  "fx_publication_id"
    t.decimal  "nz_delivery"
    t.decimal  "au_delivery"
    t.decimal  "row_delivery"
    t.decimal  "subscribers"
    t.decimal  "standard"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

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

  create_table "jive_missions", force: true do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "maintainers", force: true do |t|
    t.boolean  "pcf"
    t.integer  "assigned_to"
    t.text     "response"
    t.string   "result"
    t.string   "ticket_type"
    t.integer  "ticket_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "user_id"
    t.integer  "client_id"
    t.boolean  "resolved"
    t.string   "decision"
    t.string   "training_impact"
    t.boolean  "do_delete",       default: false
    t.integer  "admin_id"
    t.string   "lob"
  end

  create_table "message_trackers", force: true do |t|
    t.integer  "user_id"
    t.integer  "message_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "acknowledged", default: false
  end

  add_index "message_trackers", ["user_id"], name: "index_message_trackers_on_user_id", using: :btree

  create_table "messages", force: true do |t|
    t.text     "text"
    t.integer  "client_id"
    t.integer  "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean  "sent"
    t.integer  "user_id"
    t.boolean  "urgent"
  end

  create_table "missions", force: true do |t|
    t.string   "bunchball_name"
    t.string   "badge_url"
    t.string   "game_type"
    t.integer  "game_id"
    t.string   "folder"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "description"
    t.integer  "points"
    t.string   "month"
    t.integer  "client_id"
    t.string   "lob"
    t.integer  "priority",       default: 99
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

  create_table "rco_orders", force: true do |t|
    t.string   "agent_name"
    t.boolean  "created"
    t.boolean  "acct_with_password"
    t.boolean  "acct_forgot_password"
    t.boolean  "no_share"
    t.string   "order_id"
    t.integer  "lms_num"
    t.integer  "num_registrations"
    t.string   "coupon"
    t.boolean  "paypal"
    t.text     "comments"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "redeliveries", force: true do |t|
    t.integer  "fx_publication_id"
    t.string   "town"
    t.string   "round_id"
    t.boolean  "redelivery"
    t.string   "cutoff_mf"
    t.string   "cutoff_sat"
    t.string   "cutoff_sun"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "redeliveries", ["round_id"], name: "index_redeliveries_on_round_id", using: :btree
  add_index "redeliveries", ["town"], name: "index_redeliveries_on_town", using: :btree

  create_table "sf_o_auths", force: true do |t|
    t.string   "token"
    t.string   "refresh_token"
    t.string   "instance_url"
    t.integer  "user_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
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

  create_table "states", force: true do |t|
    t.string   "name"
    t.string   "abbreviation"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "suburb_fx_publications", force: true do |t|
    t.integer  "fx_publication_id"
    t.integer  "suburb_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "suburbs", force: true do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "suburbs", ["name"], name: "index_suburbs_on_name", using: :btree

  create_table "temp_users", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "oracle_id"
    t.string   "job_title"
    t.string   "client"
    t.string   "region"
    t.string   "location"
    t.string   "lob"
  end

  create_table "tokens", force: true do |t|
    t.string   "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "updates", force: true do |t|
    t.string   "text"
    t.integer  "user_id"
    t.integer  "client_id"
    t.string   "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_missions", force: true do |t|
    t.integer  "user_id"
    t.integer  "mission_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "times_completed"
    t.integer  "progress"
    t.boolean  "notify_complete"
  end

  create_table "users", force: true do |t|
    t.integer  "jive_id"
    t.string   "employee_id"
    t.integer  "client_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "password"
    t.string   "name"
    t.string   "title"
    t.string   "location"
    t.string   "lob"
    t.string   "region"
    t.string   "first_name"
    t.string   "last_name"
    t.boolean  "pending_urgent"
    t.integer  "rank"
    t.integer  "tier"
    t.string   "comp_score"
    t.integer  "team_lead_id"
  end

  add_index "users", ["employee_id"], name: "index_users_on_employee_id", using: :btree
  add_index "users", ["jive_id"], name: "index_users_on_jive_id", using: :btree

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

  create_table "ww_oprah_codes", force: true do |t|
    t.string   "code"
    t.boolean  "used",       default: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "ww_oprah_trackers", force: true do |t|
    t.string   "caller_issue"
    t.string   "referral_type"
    t.string   "member_sub"
    t.string   "non_working_code"
    t.datetime "signup_date"
    t.string   "referral_location"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "jive_username"
    t.string   "code_used"
  end

  create_table "ww_promotions", force: true do |t|
    t.string   "member_num"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "billing"
    t.string   "city"
    t.string   "state"
    t.integer  "zip"
    t.string   "agent_name"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "member_phone"
    t.text     "description"
    t.string   "meet_city"
    t.string   "meet_state"
  end

  add_index "ww_promotions", ["member_num"], name: "index_ww_promotions_on_member_num", using: :btree

end
