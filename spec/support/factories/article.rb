require File.expand_path('../factory_girl', File.dirname(__FILE__))

Factory.define :article do |a|
  a.title { Sham.random }
  a.body { Sham.lorem_ipsum }
end
