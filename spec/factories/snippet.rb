require_relative '../support/sham.rb'

FactoryGirl.define do
  factory :snippet do
    body { Sham.lorem_ipsum }
  end
end
