require File.expand_path('../factory_girl', File.dirname(__FILE__))

Factory.define :comment do |c|
  c.association :user
  c.body { Sham.lorem_ipsum }
  c.association :commentable, :factory => :article
  c.awaiting_moderation false
end
