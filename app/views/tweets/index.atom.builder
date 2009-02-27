custom_atom_feed do |feed|
  feed.title 'wincent.com: twitter'
  feed.updated @tweets.empty? ? RAILS_EPOCH : @tweets.first.updated_at
  feed.author do |author|
    author.name   'Wincent Colaiuta'
    author.email  APP_CONFIG['admin_email']
  end
  for tweet in @tweets
    feed.entry tweet do |entry|
      entry.title atom_title(tweet)
      entry.content tweet.body.w, :type => 'html'
    end
  end
end
