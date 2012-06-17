require File.expand_path('../factory_girl', File.dirname(__FILE__))

FactoryGirl.define do
  factory :snippet do
    body { Sham.lorem_ipsum }
  end
end
