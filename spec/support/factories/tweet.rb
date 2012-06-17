require File.expand_path('../factory_girl', File.dirname(__FILE__))

FactoryGirl.define do
  factory :tweet do
    body { Sham.lorem_ipsum[0..139] }
  end
end
