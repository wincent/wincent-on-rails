require File.expand_path('../factory_girl', File.dirname(__FILE__))

FactoryGirl.define do
  factory :issue do
    summary { Sham.random }
    description { Sham.random }
    awaiting_moderation false
  end
end
