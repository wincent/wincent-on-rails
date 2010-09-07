require File.expand_path('../factory_girl', File.dirname(__FILE__))

Factory.define :tag do |t|
  t.name { Sham.random }
end
