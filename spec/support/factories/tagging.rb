require File.expand_path('../factory_girl', File.dirname(__FILE__))

FactoryGirl.define do
  factory :tagging do
    association :tag
    association :taggable, :factory => :article
  end
end
