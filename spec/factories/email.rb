require_relative '../support/sham.rb'

FactoryGirl.define do
  factory :email do
    address { Sham.email_address }
    association :user
    verified true
  end
end
