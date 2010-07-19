require File.expand_path('../factory_girl.rb', File.dirname(__FILE__))

Factory.define :issue do |i|
  i.summary { Sham.random }
  i.description { Sham.random }
  i.awaiting_moderation false
end
