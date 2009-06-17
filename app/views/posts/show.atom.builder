custom_atom_feed do |feed|
  feed.title "wincent.com blog: #{@post.title}"
  feed.updated last_activity(@post, @comments)
  feed.author do |author|
    author.name   APP_CONFIG['admin_name']
    author.email  APP_CONFIG['admin_email']
  end
  feed.entry @post do |entry|
    entry.title @post.title
    entry.content @post.excerpt.w, :type => 'html'
    entry.author do |author|
      author.name   APP_CONFIG['admin_name']
      author.email  APP_CONFIG['admin_email']
    end
  end
  for comment in @comments
    feed.entry comment, :url => post_url(@post) + "\#comment_#{comment.id}" do |entry|
      entry.title "New comment (\##{@comments.index(comment) + 1}) by #{comment.user ? comment.user.display_name : 'anonymous'}"
      entry.content comment.body.w, :type => 'html'
      entry.author { |author| author.name comment.user ? comment.user.display_name : 'anonymous' }
    end
  end
end
