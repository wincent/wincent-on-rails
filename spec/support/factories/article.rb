require File.expand_path('../factory_girl.rb', File.dirname(__FILE__))

Factory.define :article do |a|
  a.title { Sham.random }
  a.body { Sham.lorem_ipsum }
end
