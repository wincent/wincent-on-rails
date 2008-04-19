class BugzillaBug < ActiveRecord::Base
  # unfortunately this will open up one connection for each of the "Bugzilla*" classes
  # but seeing as this only happens when they are actually used, this is not such a big deal
  establish_connection 'bugzilla_db'
  set_table_name 'bugs'
  set_primary_key 'bug_id'
  belongs_to :bugzilla_product, :foreign_key => :product_id
  has_many :bugzilla_comments, :foreign_key => :bug_id
end
