class BugzillaComment < ActiveRecord::Base
  # unfortunately this will open up one connection for each of the "Bugzilla*" classes
  # but seeing as this only happens when they are actually used, this is not such a big deal
  establish_connection 'bugzilla_db'
  set_table_name 'longdescs'
  set_primary_key 'comment_id'
  belongs_to :bugzilla_user, :foreign_key => :who
  belongs_to :bugzilla_bug, :foreign_key => :bug_id
end
