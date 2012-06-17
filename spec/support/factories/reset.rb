require File.expand_path('../factory_girl', File.dirname(__FILE__))

FactoryGirl.define do
  factory :reset do
    association :email

    after_build do |reset|
      reset.email_address = reset.email ? reset.email.address : nil
    end

    after_create do |reset|
      reset.email_address = reset.email.address
    end
  end
end
