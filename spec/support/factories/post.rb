require File.expand_path('../factory_girl.rb', File.dirname(__FILE__))

Factory.define :post do |p|
  p.title { Sham.random }
  p.permalink { Sham.random }
  p.excerpt { Sham.lorem_ipsum }
end
