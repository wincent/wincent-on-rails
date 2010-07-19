require File.expand_path('../factory_girl.rb', File.dirname(__FILE__))

Factory.define :tweet do |t|
  t.body { Sham.lorem_ipsum[0..139] }
end
