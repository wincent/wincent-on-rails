class UbbPost < ActiveRecord::Base
  # unfortunately this will open up one connection for each of the "Ubb*" classes
  # but seeing as this only happens when they are actually used, this is not such a big deal
  establish_connection 'ubb_db'
  set_table_name 'ubbt_POSTS'
  set_primary_key 'POST_ID'
  belongs_to :ubb_topic, :foreign_key => :TOPIC_ID
  belongs_to :ubb_user, :foreign_key => :USER_ID
end
