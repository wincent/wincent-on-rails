class BugzillaProduct < ActiveRecord::Base
  # unfortunately this will open up one connection for each of the "Bugzilla*" classes
  # but seeing as this only happens when they are actually used, this is not such a big deal
  establish_connection 'bugzilla_db'
  set_table_name 'products'
  set_primary_key 'id'
  has_many :bugzilla_bugs, :foreign_key => :product_id
end
