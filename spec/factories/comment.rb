FactoryGirl.define do
  factory :comment do
    association :user
    body { Sham.lorem_ipsum }
    association :commentable, :factory => :article
    awaiting_moderation false
  end
end
