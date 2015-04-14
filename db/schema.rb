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

ActiveRecord::Schema.define(version: 20150414010714) do

  create_table "articles", force: :cascade do |t|
    t.string   "title",             limit: 255
    t.string   "redirect",          limit: 255
    t.text     "body",              limit: 16777215
    t.boolean  "public",            limit: 1,        default: true
    t.boolean  "accepts_comments",  limit: 1,        default: true
    t.integer  "comments_count",    limit: 4,        default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "last_commenter_id", limit: 4
    t.integer  "last_comment_id",   limit: 4
    t.datetime "last_commented_at"
  end

  add_index "articles", ["title"], name: "index_articles_on_title", unique: true, using: :btree

  create_table "attachments", force: :cascade do |t|
    t.string   "digest",              limit: 255
    t.string   "path",                limit: 255
    t.string   "mime_type",           limit: 255
    t.integer  "user_id",             limit: 4
    t.string   "original_filename",   limit: 255
    t.integer  "filesize",            limit: 4
    t.integer  "attachable_id",       limit: 4
    t.string   "attachable_type",     limit: 255
    t.boolean  "awaiting_moderation", limit: 1,   default: true
    t.boolean  "public",              limit: 1,   default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attachments", ["digest"], name: "index_attachments_on_digest", unique: true, using: :btree

  create_table "comments", force: :cascade do |t|
    t.text     "body",                limit: 16777215
    t.integer  "user_id",             limit: 4
    t.integer  "commentable_id",      limit: 4
    t.string   "commentable_type",    limit: 255
    t.boolean  "awaiting_moderation", limit: 1,        default: true
    t.boolean  "public",              limit: 1,        default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "confirmations", force: :cascade do |t|
    t.integer  "email_id",     limit: 4
    t.string   "secret",       limit: 255
    t.datetime "cutoff"
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "emails", force: :cascade do |t|
    t.integer  "user_id",    limit: 4,                   null: false
    t.string   "address",    limit: 255
    t.boolean  "default",    limit: 1,   default: true
    t.boolean  "verified",   limit: 1,   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "emails", ["address"], name: "index_emails_on_address", unique: true, using: :btree

  create_table "forums", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.string   "description",  limit: 255
    t.integer  "topics_count", limit: 4,   default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position",     limit: 4
    t.boolean  "public",       limit: 1,   default: true
    t.string   "permalink",    limit: 255
  end

  add_index "forums", ["name"], name: "index_forums_on_name", unique: true, using: :btree
  add_index "forums", ["permalink"], name: "index_forums_on_permalink", unique: true, using: :btree

  create_table "issues", force: :cascade do |t|
    t.integer  "kind",                limit: 4,        default: 0
    t.string   "summary",             limit: 255
    t.boolean  "public",              limit: 1,        default: true
    t.integer  "user_id",             limit: 4
    t.integer  "status",              limit: 4,        default: 1
    t.text     "description",         limit: 16777215
    t.boolean  "awaiting_moderation", limit: 1,        default: true
    t.integer  "comments_count",      limit: 4,        default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "last_commenter_id",   limit: 4
    t.integer  "last_comment_id",     limit: 4
    t.datetime "last_commented_at"
    t.integer  "product_id",          limit: 4
    t.boolean  "accepts_comments",    limit: 1,        default: true
  end

  create_table "links", force: :cascade do |t|
    t.string   "uri",         limit: 255
    t.string   "permalink",   limit: 255
    t.integer  "click_count", limit: 4,   default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "links", ["permalink"], name: "index_links_on_permalink", unique: true, using: :btree
  add_index "links", ["uri"], name: "index_links_on_uri", unique: true, using: :btree

  create_table "messages", force: :cascade do |t|
    t.integer  "related_id",         limit: 4
    t.string   "related_type",       limit: 255
    t.string   "message_id_header",  limit: 255
    t.string   "to_header",          limit: 255
    t.string   "from_header",        limit: 255
    t.string   "subject_header",     limit: 255
    t.string   "in_reply_to_header", limit: 255
    t.text     "body",               limit: 65535
    t.boolean  "incoming",           limit: 1,     default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "monitorships", force: :cascade do |t|
    t.integer  "user_id",          limit: 4
    t.integer  "monitorable_id",   limit: 4
    t.string   "monitorable_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "needles", force: :cascade do |t|
    t.string  "model_class",    limit: 255
    t.integer "model_id",       limit: 4
    t.string  "attribute_name", limit: 255
    t.string  "content",        limit: 255
    t.integer "user_id",        limit: 4
    t.boolean "public",         limit: 1
  end

  add_index "needles", ["content", "attribute_name"], name: "index_needles_on_content_and_attribute_name", using: :btree
  add_index "needles", ["model_id", "model_class"], name: "index_needles_on_model_id_and_model_class", using: :btree

  create_table "pages", force: :cascade do |t|
    t.string   "title",       limit: 255
    t.string   "permalink",   limit: 255
    t.text     "body",        limit: 65535
    t.boolean  "front",       limit: 1,     default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "product_id",  limit: 4
    t.integer  "markup_type", limit: 4,     default: 0
  end

  create_table "posts", force: :cascade do |t|
    t.string   "title",             limit: 255
    t.string   "permalink",         limit: 255
    t.text     "excerpt",           limit: 65535
    t.text     "body",              limit: 16777215
    t.boolean  "public",            limit: 1,        default: true
    t.boolean  "accepts_comments",  limit: 1,        default: true
    t.integer  "comments_count",    limit: 4,        default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "last_commenter_id", limit: 4
    t.integer  "last_comment_id",   limit: 4
    t.datetime "last_commented_at"
  end

  add_index "posts", ["permalink"], name: "index_posts_on_permalink", unique: true, using: :btree

  create_table "products", force: :cascade do |t|
    t.string   "name",                 limit: 255
    t.string   "permalink",            limit: 255
    t.text     "description",          limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "bundle_identifier",    limit: 255
    t.text     "header",               limit: 65535
    t.text     "footer",               limit: 65535
    t.integer  "position",             limit: 4
    t.string   "category",             limit: 255
    t.boolean  "hide_from_front_page", limit: 1,     default: true
  end

  add_index "products", ["bundle_identifier"], name: "index_products_on_bundle_identifier", unique: true, using: :btree
  add_index "products", ["name"], name: "index_products_on_name", unique: true, using: :btree
  add_index "products", ["permalink"], name: "index_products_on_permalink", unique: true, using: :btree

  create_table "repos", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.string   "permalink",    limit: 255
    t.string   "path",         limit: 255
    t.string   "description",  limit: 255
    t.integer  "product_id",   limit: 4
    t.boolean  "public",       limit: 1,   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "clone_url",    limit: 255
    t.string   "rw_clone_url", limit: 255
  end

  add_index "repos", ["clone_url"], name: "index_repos_on_clone_url", unique: true, using: :btree
  add_index "repos", ["name"], name: "index_repos_on_name", unique: true, using: :btree
  add_index "repos", ["path"], name: "index_repos_on_path", unique: true, using: :btree
  add_index "repos", ["permalink"], name: "index_repos_on_permalink", unique: true, using: :btree
  add_index "repos", ["product_id"], name: "index_repos_on_product_id", unique: true, using: :btree
  add_index "repos", ["rw_clone_url"], name: "index_repos_on_rw_clone_url", unique: true, using: :btree

  create_table "resets", force: :cascade do |t|
    t.string   "secret",       limit: 255
    t.datetime "cutoff"
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "email_id",     limit: 4
  end

  create_table "snippets", force: :cascade do |t|
    t.string   "description",       limit: 255
    t.integer  "markup_type",       limit: 4,     default: 0
    t.text     "body",              limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "public",            limit: 1,     default: true
    t.integer  "comments_count",    limit: 4,     default: 0
    t.boolean  "accepts_comments",  limit: 1,     default: true
    t.integer  "last_commenter_id", limit: 4
    t.integer  "last_comment_id",   limit: 4
    t.datetime "last_commented_at"
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id",        limit: 4
    t.integer  "taggable_id",   limit: 4
    t.string   "taggable_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type"], name: "index_taggings_on_tag_id_and_taggable_id_and_taggable_type", unique: true, using: :btree

  create_table "tags", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.integer  "taggings_count", limit: 4,   default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree
  add_index "tags", ["taggings_count", "name"], name: "index_tags_on_taggings_count_and_name", using: :btree

  create_table "topics", force: :cascade do |t|
    t.string   "title",               limit: 255
    t.text     "body",                limit: 16777215
    t.integer  "forum_id",            limit: 4
    t.integer  "user_id",             limit: 4
    t.boolean  "public",              limit: 1,        default: true
    t.boolean  "accepts_comments",    limit: 1,        default: true
    t.boolean  "awaiting_moderation", limit: 1,        default: true
    t.integer  "comments_count",      limit: 4,        default: 0
    t.integer  "view_count",          limit: 4,        default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "last_commenter_id",   limit: 4
    t.integer  "last_comment_id",     limit: 4
    t.datetime "last_commented_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "display_name",    limit: 255
    t.string   "passphrase_hash", limit: 255
    t.string   "passphrase_salt", limit: 255
    t.boolean  "superuser",       limit: 1,   default: false
    t.boolean  "verified",        limit: 1,   default: false
    t.boolean  "suspended",       limit: 1,   default: false
    t.string   "session_key",     limit: 255
    t.datetime "session_expiry"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "comments_count",  limit: 4,   default: 0
    t.integer  "topics_count",    limit: 4,   default: 0
    t.integer  "hash_version",    limit: 4,   default: 1
  end

  add_index "users", ["display_name"], name: "index_users_on_display_name", unique: true, using: :btree

  create_table "words", force: :cascade do |t|
    t.string   "token",          limit: 255
    t.integer  "count",          limit: 4
    t.integer  "classification", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
