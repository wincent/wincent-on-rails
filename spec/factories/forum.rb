require_relative '../support/sham.rb'

FactoryGirl.define do
  factory :forum do
    name { Sham.random }
  end
end
