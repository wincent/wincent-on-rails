require 'factory_girl/syntax/sham'

Sham.post_title do |n|
  if Rails.env == 'development'
    "Random post on #{Sham.random}"
  else
    "Post number #{n}"
  end
end

Sham.post_permalink do |n|
  if Rails.env == 'development'
    "random-post-#{rand(1000)}-#{n}"
  else
    "post-#{n}"
  end
end

Sham.post_excerpt do |n|
  "Excerpt #{n}."
end

Factory.define :post do |p|
  p.title { Sham.post_title }
  p.permalink { Sham.post_permalink }
  p.excerpt { Sham.post_excerpt }
end
