custom_atom_feed do |feed|
  feed.title 'wincent.com: snippets'
  feed.updated @snippets.empty? ? RAILS_EPOCH : @snippets.first.updated_at
  feed.author do |author|
    author.name   APP_CONFIG['admin_name']
    author.email  APP_CONFIG['admin_email']
  end
  @snippets.each do |snippet|
    feed.entry snippet do |entry|
      entry.title snippet_title(snippet)
      entry.content snippet.body_html, :type => 'html'
    end
  end
end
