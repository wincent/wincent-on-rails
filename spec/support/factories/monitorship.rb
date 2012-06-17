require File.expand_path('../factory_girl', File.dirname(__FILE__))

FactoryGirl.define do
  factory :monitorship do
    association :monitorable, :factory => :issue
    association :user
  end
end
