require File.expand_path('../factory_girl', File.dirname(__FILE__))

FactoryGirl.define do
  factory :page do
    title { Sham.random }
    permalink { Sham.random }
    body { "<p>#{Sham.lorem_ipsum}</p>" }
  end
end
