#   string   "name",                           :null => false
#   string   "permalink",                      :null => false
#   string   "path",                           :null => false
#   string   "description"
#   integer  "product_id"
#   boolean  "public",      :default => false
#   datetime "created_at"
#   datetime "updated_at"
class Repo < ActiveRecord::Base
  validates_presence_of :name, :path, :permalink
end
