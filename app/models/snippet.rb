# Schema:
#
#   string   "description"
#   integer  "markup",         :default => 0
#   text     "body"
#   datetime "created_at"
#   datetime "updated_at"
#   boolean  "public",         :default => true
#   integer  "comments_count", :default => 0
class Snippet < ActiveRecord::Base
end
