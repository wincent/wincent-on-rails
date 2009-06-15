custom_atom_feed do |feed|
  feed.title "wincent.com tweet \##{@tweet.id}"
  feed.updated last_activity(@tweet, @comments)
  feed.author do |author|
    author.name   'Wincent Colaiuta'
    author.email  APP_CONFIG['admin_email']
  end
  feed.entry @tweet do |entry|
    entry.title "Tweet \##{@tweet.id}"
    entry.content @tweet.body.w, :type => 'html'
    entry.author do |author|
      author.name   'Wincent Colaiuta'
      author.email  APP_CONFIG['admin_email']
    end
  end
  for comment in @comments
    feed.entry comment, :url => tweet_url(@tweet) + "\#comment_#{comment.id}" do |entry|
      entry.title "New comment (\##{@comments.index(comment) + 1}) by #{comment.user ? comment.user.display_name : 'anonymous'}"
      entry.content comment.body.w, :type => 'html'
      entry.author { |author| author.name comment.user ? comment.user.display_name : 'anonymous' }
    end
  end
end
