require File.expand_path('../factory_girl', File.dirname(__FILE__))

FactoryGirl.define do
  factory :link do
    uri { "http://#{Sham.random}/#{Sham.random}" }
    permalink { Sham.random }
  end
end
