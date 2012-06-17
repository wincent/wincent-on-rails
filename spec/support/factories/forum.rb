require File.expand_path('../factory_girl', File.dirname(__FILE__))

FactoryGirl.define do
  factory :forum do
    name { Sham.random }
  end
end
