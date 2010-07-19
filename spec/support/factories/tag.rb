require File.expand_path('../factory_girl.rb', File.dirname(__FILE__))

Factory.define :tag do |t|
  t.name { Sham.random }
end
