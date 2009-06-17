custom_atom_feed do |feed|
  feed.title 'wincent.com: wiki'
  feed.updated @articles.empty? ? RAILS_EPOCH : @articles.first.updated_at
  feed.author do |author|
    author.name   APP_CONFIG['admin_name']
    author.email  APP_CONFIG['admin_email']
  end
  for article in @articles
    next if article.redirect?
    feed.entry article do |entry|
      entry.title article.title
      entry.content article.body.w, :type => 'html'
    end
  end
end
