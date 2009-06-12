updated_at = @article.updated_at
unless @comments.empty?
  if @article.last_commented_at > updated_at
    updated_at = @article.last_commented_at
  end
end

custom_atom_feed do |feed|
  feed.title "wincent.com wiki: #{@article.title}"
  feed.updated updated_at
  feed.author do |author|
    author.name   'Wincent Colaiuta'
    author.email  APP_CONFIG['admin_email']
  end
  feed.entry @article do |entry|
    entry.title @article.title
    entry.content @article.body.w, :type => 'html'
    entry.author do |author|
      author.name 'Wincent Colaiuta'
      author.email APP_CONFIG['admin_email']
    end
  end
  for comment in @comments
    feed.entry comment, :url => article_url(@article) + "\#comment_#{comment.id}" do |entry|
      entry.title "New comment (\##{@comments.index(comment) + 1}) by #{comment.user ? comment.user.display_name : 'anonymous'}"
      entry.content comment.body.w, :type => 'html'
      entry.author { |author| author.name comment.user ? comment.user.display_name : 'anonymous' }
    end
  end
end
