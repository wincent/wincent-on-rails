require File.expand_path('../factory_girl', File.dirname(__FILE__))

FactoryGirl.define  do
  factory :post do
    title { Sham.random }
    permalink { Sham.random }
    excerpt { Sham.lorem_ipsum }
  end
end
