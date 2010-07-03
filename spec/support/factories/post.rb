Factory.define :post do |p|
  p.title { Sham.random }
  p.permalink { Sham.random }
  p.excerpt { Sham.lorem_ipsum }
end
