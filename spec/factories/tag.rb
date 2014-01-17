require_relative '../support/sham.rb'

FactoryGirl.define do
  factory :tag do
    name { Sham.random }
  end
end
