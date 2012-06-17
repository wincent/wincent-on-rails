require File.expand_path('../factory_girl', File.dirname(__FILE__))

FactoryGirl.define do
  factory :topic do
    association :forum
    title { Sham.random }
    body { Sham.lorem_ipsum }
    awaiting_moderation false
  end
end
