# TODO: turn this into a helper
updated_at = @tweet.updated_at
unless @comments.empty?
  if @tweet.last_commented_at > updated_at
    updated_at = @tweet.last_commented_at
  end
end

custom_atom_feed do |feed|
  feed.title "wincent.com tweet \##{@tweet.id}"
  feed.updated updated_at
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
