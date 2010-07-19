require File.expand_path('../factory_girl.rb', File.dirname(__FILE__))

Factory.define :monitorship do |m|
  m.association :monitorable, :factory => :issue
  m.association :user
end
