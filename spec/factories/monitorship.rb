FactoryGirl.define do
  factory :monitorship do
    association :monitorable, :factory => :issue
    association :user
  end
end
