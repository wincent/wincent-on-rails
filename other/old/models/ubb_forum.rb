class UbbForum < ActiveRecord::Base
  # unfortunately this will open up one connection for each of the "Ubb*" classes
  # but seeing as this only happens when they are actually used, this is not such a big deal
  establish_connection 'ubb_db'
  set_table_name 'ubbt_FORUMS'
  set_primary_key 'FORUM_ID'
  has_many :ubb_topics, :foreign_key => :FORUM_ID
end
