FactoryGirl.define do
  factory :issue do
    summary { Sham.random }
    description { Sham.random }
    awaiting_moderation false
  end
end
