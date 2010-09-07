require File.expand_path('../factory_girl', File.dirname(__FILE__))

Factory.define :page do |p|
  p.title { Sham.random }
  p.permalink { Sham.random }
  p.body { "<p>#{Sham.lorem_ipsum}</p>" }
end
