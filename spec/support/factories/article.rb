require File.expand_path('../factory_girl', File.dirname(__FILE__))

FactoryGirl.define do
  factory :article do
    title { Sham.random }
    body  { Sham.lorem_ipsum }
  end
end
