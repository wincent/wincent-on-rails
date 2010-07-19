require File.expand_path('../factory_girl.rb', File.dirname(__FILE__))

Factory.define :tagging do |t|
  t.association :tag
  t.association :taggable, :factory => :article
end
