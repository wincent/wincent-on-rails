require File.expand_path('../factory_girl', File.dirname(__FILE__))

FactoryGirl.define do
  factory :email do
    address { Sham.email_address }
    association :user
    verified true
  end
end
