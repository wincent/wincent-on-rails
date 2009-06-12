updated_at = @post.updated_at
unless @comments.empty?
  if @post.last_commented_at > updated_at
    updated_at = @post.last_commented_at
  end
end

custom_atom_feed do |feed|
  feed.title "wincent.com blog: #{@post.title}"
  feed.updated updated_at
  feed.author do |author|
    author.name   'Wincent Colaiuta'
    author.email  APP_CONFIG['admin_email']
  end
  feed.entry @post do |entry|
    entry.title @post.title
    entry.content @post.excerpt.w, :type => 'html'
    entry.author do |author|
      author.name   'Wincent Colaiuta'
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
