custom_atom_feed do |feed|
  feed.title 'wincent.com: blog'
  feed.updated @posts.empty? ? RAILS_EPOCH : @posts.first.created_at
  feed.author do |author|
    author.name   APP_CONFIG['admin_name']
    author.email  APP_CONFIG['admin_email']
  end
  for post in @posts
    feed.entry post do |entry|
      entry.title post.title
      entry.summary post.excerpt.w, :type => 'html'
      entry.content :src => post_url(post)
    end
  end
end
