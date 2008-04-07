class BugzillaUser < ActiveRecord::Base
  # unfortunately this will open up one connection for each of the "Bugzilla*" classes
  # but seeing as this only happens when they are actually used, this is not such a big deal
  establish_connection 'bugzilla_db'
  set_table_name 'profiles'
  set_primary_key 'userid'
  has_many :bugzilla_comments, :foreign_key => :who
end
