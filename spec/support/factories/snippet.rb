require File.expand_path('../factory_girl', File.dirname(__FILE__))

Factory.define :snippet do |s|
  s.body { Sham.lorem_ipsum }
end
