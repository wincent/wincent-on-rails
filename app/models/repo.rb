#   string   "name",                           :null => false
#   string   "permalink",                      :null => false
#   string   "path",                           :null => false
#   string   "description"
#   integer  "product_id"
#   boolean  "public",      :default => false
#   datetime "created_at"
#   datetime "updated_at"
class Repo < ActiveRecord::Base
  belongs_to :product
  validates_presence_of :name, :path, :permalink
  validates_format_of :path, :with => %r{\A(/([a-z0-9._-]+))+\z}i,
    :message => 'must have format "/foo/bar/baz"'
end
