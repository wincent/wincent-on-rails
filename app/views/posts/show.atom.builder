custom_atom_feed do |feed|
  feed.title "wincent.com blog: #{@post.title}"
  feed.updated @comments.empty? ? @post.created_at : @post.last_commented_at
  for comment in @comments
    feed.entry comment, :url => post_url(@post) + "\#comment_#{comment.id}" do |entry|
      entry.title "New comment (\##{@comments.index(comment) + 1}) by #{comment.user ? comment.user.display_name : 'anonymous'}"
      entry.content comment.body.w, :type => 'html'
      entry.author { |author| author.name comment.user ? comment.user.display_name : 'anonymous' }
    end
  end
end
