Sham.post_title do |n|
  "Post number #{n}"
end

Sham.post_permalink do |n|
  "post-#{n}"
end

Sham.post_excerpt do |n|
  "Excerpt #{n}."
end

Factory.define :post do |p|
  p.title { Sham.post_title }
  p.permalink { Sham.post_permalink }
  p.excerpt { Sham.post_excerpt }
end
