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

ActiveRecord::Schema.define(:version => 20110531061835) do

  create_table "articles", :force => true do |t|
    t.string   "title"
    t.string   "redirect"
    t.text     "body",              :limit => 16777215
    t.boolean  "public",                                :default => true
    t.boolean  "accepts_comments",                      :default => true
    t.integer  "comments_count",                        :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "last_commenter_id"
    t.integer  "last_comment_id"
    t.datetime "last_commented_at"
  end

  add_index "articles", ["title"], :name => "index_articles_on_title", :unique => true

  create_table "attachments", :force => true do |t|
    t.string   "digest"
    t.string   "path"
    t.string   "mime_type"
    t.integer  "user_id"
    t.string   "original_filename"
    t.integer  "filesize"
    t.integer  "attachable_id"
    t.string   "attachable_type"
    t.boolean  "awaiting_moderation", :default => true
    t.boolean  "public",              :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attachments", ["digest"], :name => "index_attachments_on_digest", :unique => true

  create_table "comments", :force => true do |t|
    t.text     "body",                :limit => 16777215
    t.integer  "user_id"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.boolean  "awaiting_moderation",                     :default => true
    t.boolean  "public",                                  :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "confirmations", :force => true do |t|
    t.integer  "email_id"
    t.string   "secret"
    t.datetime "cutoff"
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "emails", :force => true do |t|
    t.integer  "user_id",                       :null => false
    t.string   "address"
    t.boolean  "default",    :default => true
    t.boolean  "verified",   :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "emails", ["address"], :name => "index_emails_on_address", :unique => true

  create_table "forums", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "topics_count", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.boolean  "public",       :default => true
    t.string   "permalink"
  end

  add_index "forums", ["name"], :name => "index_forums_on_name", :unique => true
  add_index "forums", ["permalink"], :name => "index_forums_on_permalink", :unique => true

  create_table "issues", :force => true do |t|
    t.integer  "kind",                                    :default => 0
    t.string   "summary"
    t.boolean  "public",                                  :default => true
    t.integer  "user_id"
    t.integer  "status",                                  :default => 0
    t.text     "description",         :limit => 16777215
    t.boolean  "awaiting_moderation",                     :default => true
    t.integer  "comments_count",                          :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "last_commenter_id"
    t.integer  "last_comment_id"
    t.datetime "last_commented_at"
    t.integer  "product_id"
    t.boolean  "accepts_comments",                        :default => true
  end

  create_table "links", :force => true do |t|
    t.string   "uri"
    t.string   "permalink"
    t.integer  "click_count", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "links", ["permalink"], :name => "index_links_on_permalink", :unique => true
  add_index "links", ["uri"], :name => "index_links_on_uri", :unique => true

  create_table "messages", :force => true do |t|
    t.integer  "related_id"
    t.string   "related_type"
    t.string   "message_id_header"
    t.string   "to_header"
    t.string   "from_header"
    t.string   "subject_header"
    t.string   "in_reply_to_header"
    t.text     "body"
    t.boolean  "incoming",           :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "monitorships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "monitorable_id"
    t.string   "monitorable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "needles", :force => true do |t|
    t.string  "model_class"
    t.integer "model_id"
    t.string  "attribute_name"
    t.string  "content"
    t.integer "user_id"
    t.boolean "public"
  end

  create_table "pages", :force => true do |t|
    t.string   "title"
    t.string   "permalink"
    t.text     "body"
    t.boolean  "front",       :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "product_id"
    t.integer  "markup_type", :default => 0
  end

  create_table "posts", :force => true do |t|
    t.string   "title"
    t.string   "permalink"
    t.text     "excerpt"
    t.text     "body",              :limit => 16777215
    t.boolean  "public",                                :default => true
    t.boolean  "accepts_comments",                      :default => true
    t.integer  "comments_count",                        :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "last_commenter_id"
    t.integer  "last_comment_id"
    t.datetime "last_commented_at"
  end

  add_index "posts", ["permalink"], :name => "index_posts_on_permalink", :unique => true

  create_table "products", :force => true do |t|
    t.string   "name"
    t.string   "permalink"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "bundle_identifier"
    t.text     "header"
    t.text     "footer"
    t.integer  "position"
    t.string   "category"
    t.boolean  "hide_from_front_page", :default => true
  end

  add_index "products", ["bundle_identifier"], :name => "index_products_on_bundle_identifier", :unique => true
  add_index "products", ["name"], :name => "index_products_on_name", :unique => true
  add_index "products", ["permalink"], :name => "index_products_on_permalink", :unique => true

  create_table "repos", :force => true do |t|
    t.string   "name"
    t.string   "permalink"
    t.string   "path"
    t.string   "description"
    t.integer  "product_id"
    t.boolean  "public",       :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "clone_url"
    t.string   "rw_clone_url"
  end

  add_index "repos", ["clone_url"], :name => "index_repos_on_clone_url", :unique => true
  add_index "repos", ["name"], :name => "index_repos_on_name", :unique => true
  add_index "repos", ["path"], :name => "index_repos_on_path", :unique => true
  add_index "repos", ["permalink"], :name => "index_repos_on_permalink", :unique => true
  add_index "repos", ["product_id"], :name => "index_repos_on_product_id", :unique => true
  add_index "repos", ["rw_clone_url"], :name => "index_repos_on_rw_clone_url", :unique => true

  create_table "resets", :force => true do |t|
    t.string   "secret"
    t.datetime "cutoff"
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "email_id"
  end

  create_table "snippets", :force => true do |t|
    t.string   "description"
    t.integer  "markup_type",       :default => 0
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "public",            :default => true
    t.integer  "comments_count",    :default => 0
    t.boolean  "accepts_comments",  :default => true
    t.integer  "last_commenter_id"
    t.integer  "last_comment_id"
    t.datetime "last_commented_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type"], :name => "index_taggings_on_tag_id_and_taggable_id_and_taggable_type", :unique => true

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.integer  "taggings_count", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["name"], :name => "index_tags_on_name", :unique => true

  create_table "topics", :force => true do |t|
    t.string   "title"
    t.text     "body",                :limit => 16777215
    t.integer  "forum_id"
    t.integer  "user_id"
    t.boolean  "public",                                  :default => true
    t.boolean  "accepts_comments",                        :default => true
    t.boolean  "awaiting_moderation",                     :default => true
    t.integer  "comments_count",                          :default => 0
    t.integer  "view_count",                              :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "last_commenter_id"
    t.integer  "last_comment_id"
    t.datetime "last_commented_at"
  end

  create_table "tweets", :force => true do |t|
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "accepts_comments",  :default => true
    t.integer  "comments_count",    :default => 0
    t.integer  "last_commenter_id"
    t.integer  "last_comment_id"
    t.datetime "last_commented_at"
  end

  create_table "users", :force => true do |t|
    t.string   "display_name"
    t.string   "passphrase_hash"
    t.string   "passphrase_salt"
    t.boolean  "superuser",       :default => false
    t.boolean  "verified",        :default => false
    t.boolean  "suspended",       :default => false
    t.string   "session_key"
    t.datetime "session_expiry"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "comments_count",  :default => 0
    t.integer  "topics_count",    :default => 0
  end

  add_index "users", ["display_name"], :name => "index_users_on_display_name", :unique => true

  create_table "words", :force => true do |t|
    t.string   "token"
    t.integer  "count"
    t.integer  "classification"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
