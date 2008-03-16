class UbbUser < ActiveRecord::Base
  # unfortunately this will open up one connection for each of the "Ubb*" classes
  # but seeing as this only happens when they are actually used, this is not such a big deal
  establish_connection 'ubb_db'
  set_table_name 'ubbt_USERS'
  set_primary_key 'USER_ID'
  has_many :ubb_posts, :foreign_key => :USER_ID
  has_many :ubb_topics, :foreign_key => :USER_ID
end
