require_relative '../support/sham.rb'

FactoryGirl.define do
  factory :topic do
    association :forum
    title { Sham.random }
    body { Sham.lorem_ipsum }
    awaiting_moderation false
  end
end
