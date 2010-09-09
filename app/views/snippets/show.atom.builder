custom_atom_feed do |feed|
  feed.title "wincent.com snippet: #{snippet_title @snippet}"
  feed.updated last_activity(@snippet, @comments)
  feed.author do |author|
    author.name   APP_CONFIG['admin_name']
    author.email  APP_CONFIG['admin_email']
  end
  feed.entry @snippet do |entry|
    entry.title snippet_title(@snippet)
    entry.content @snippet.body_html, :type => 'html'
    entry.author do |author|
      author.name   APP_CONFIG['admin_name']
      author.email  APP_CONFIG['admin_email']
    end
  end
  @comments.each do |comment|
    url = snippet_url(@snippet) + "\#comment_#{comment.id}"
    feed.entry comment, :url => url  do |entry|
      entry.title "New comment (\##{@comments.index(comment) + 1}) by #{comment.user ? comment.user.display_name : 'anonymous'}"
      entry.content comment.body.w, :type => 'html'
      entry.author { |author| author.name comment.user ? comment.user.display_name : 'anonymous' }
    end
  end
end
