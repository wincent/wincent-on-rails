custom_atom_feed do |feed|
  feed.title 'wincent.com: blog'
  feed.updated @posts.first.created_at
  feed.author do |author|
    author.name   'Wincent Colaiuta'
    author.email  'win@wincent.com'
  end
  for post in @posts
    feed.entry(post, :url => blog_url(post)) do |entry|
      entry.title post.title
      entry.summary post.excerpt.w, :type => 'html'
      entry.content :src => blog_url(post)
    end
  end
end
