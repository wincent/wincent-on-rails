Factory.define :page do |p|
  p.title { Sham.random }
  p.permalink { Sham.random }
  p.body { "<p>#{Sham.lorem_ipsum}</p>" }
end
