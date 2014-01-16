FactoryGirl.define do
  factory :tagging do
    association :tag
    association :taggable, :factory => :article
  end
end
