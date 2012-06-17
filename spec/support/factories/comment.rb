require File.expand_path('../factory_girl', File.dirname(__FILE__))

FactoryGirl.define do
  factory :comment do
    association :user
    body { Sham.lorem_ipsum }
    association :commentable, :factory => :article
    awaiting_moderation false
  end
end
