# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 15) do

  create_table "articles", :force => true do |t|
    t.string   "title"
    t.string   "redirect"
    t.boolean  "public"
    t.boolean  "accepts_comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", :force => true do |t|
    t.text     "body",                :default => "",    :null => false
    t.integer  "user_id",                                :null => false
    t.integer  "commentable_id",                         :null => false
    t.string   "commentable_type",    :default => "",    :null => false
    t.boolean  "awaiting_moderation", :default => true
    t.boolean  "spam",                :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "emails", :force => true do |t|
    t.integer  "user_id"
    t.string   "address",            :default => "",    :null => false
    t.boolean  "verified",           :default => false, :null => false
    t.string   "verification_key"
    t.datetime "verification_limit"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "emails", ["address"], :name => "index_emails_on_address", :unique => true

  create_table "issues", :force => true do |t|
    t.integer  "type"
    t.string   "summary",             :default => "",    :null => false
    t.integer  "status_id",                              :null => false
    t.boolean  "public"
    t.integer  "user_id"
    t.text     "description"
    t.boolean  "awaiting_moderation", :default => true
    t.boolean  "spam",                :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "links", :force => true do |t|
    t.string   "uri",         :default => "", :null => false
    t.string   "permalink"
    t.integer  "click_count", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "links", ["uri"], :name => "index_links_on_uri", :unique => true
  add_index "links", ["permalink"], :name => "index_links_on_permalink", :unique => true

  create_table "locales", :force => true do |t|
    t.string   "code",        :default => "", :null => false
    t.string   "description", :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "needles", :force => true do |t|
    t.string   "model_class",    :default => "", :null => false
    t.integer  "model_id",                       :null => false
    t.string   "attribute_name", :default => "", :null => false
    t.string   "content",        :default => "", :null => false
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "revisions", :force => true do |t|
    t.text     "wikitext"
    t.text     "html"
    t.boolean  "public"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :default => "", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "statuses", :force => true do |t|
    t.string   "name",        :default => "",    :null => false
    t.string   "description", :default => "",    :null => false
    t.boolean  "closed",      :default => true,  :null => false
    t.boolean  "is_default",  :default => false, :null => false
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "statuses", ["name"], :name => "index_statuses_on_name", :unique => true

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id",                   :null => false
    t.string   "taggable_type", :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type"], :name => "index_taggings_on_tag_id_and_taggable_id_and_taggable_type", :unique => true

  create_table "tags", :force => true do |t|
    t.string   "name",       :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "translations", :force => true do |t|
    t.integer  "locale_id"
    t.string   "key"
    t.string   "translation"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "translations", ["locale_id", "key"], :name => "index_translations_on_locale_id_and_key", :unique => true

  create_table "users", :force => true do |t|
    t.string   "login_name",      :default => "",    :null => false
    t.string   "display_name",    :default => "",    :null => false
    t.string   "passphrase_hash", :default => "",    :null => false
    t.string   "passphrase_salt", :default => "",    :null => false
    t.integer  "locale_id"
    t.boolean  "superuser",       :default => false
    t.boolean  "verified",        :default => false
    t.boolean  "suspended",       :default => false
    t.string   "session_key"
    t.datetime "session_expiry"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["login_name"], :name => "index_users_on_login_name", :unique => true
  add_index "users", ["display_name"], :name => "index_users_on_display_name", :unique => true

  create_table "words", :force => true do |t|
    t.string   "token"
    t.integer  "count"
    t.integer  "classification"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
