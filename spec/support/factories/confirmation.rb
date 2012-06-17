require File.expand_path('../factory_girl', File.dirname(__FILE__))

FactoryGirl.define do
  factory :confirmation do
    association :email
  end
end
