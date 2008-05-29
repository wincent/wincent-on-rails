custom_atom_feed do |feed|
  feed.title 'wincent.com: wiki'
  feed.updated @articles.first.updated_at
  feed.author do |author|
    author.name   'Wincent Colaiuta'
    author.email  APP_CONFIG['admin_email']
  end
  for article in @articles
    next if article.redirect?
    feed.entry(article, :url => article_url(article)) do |entry|
      entry.title article.title
      entry.content article.body.w, :type => 'html'
    end
  end
end
