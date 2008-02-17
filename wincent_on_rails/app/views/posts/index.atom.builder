custom_atom_feed do |feed|
  feed.title 'wincent.com: blog'
  feed.updated @posts.first.created_at
  for post in @posts
    feed.entry(post, :url => blog_url(post)) do |entry|
      entry.title post.title
      entry.content post.excerpt.w, :type => 'html'
    end
  end
end
