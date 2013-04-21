class AddTwitterIdAndTwitterIdStrToTweets < ActiveRecord::Migration
  def change
    # https://groups.google.com/forum/?fromgroups=#!topic/twitter-api-announce/ahbvo3VTIYI
    add_column :tweets, :twitter_id,     :integer, limit: 8 # bigint
    add_column :tweets, :twitter_id_str, :string
  end
end
