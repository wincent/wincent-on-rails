require File.expand_path('../factory_girl', File.dirname(__FILE__))

Factory.define :forum do |f|
  f.name { Sham.random }
end
