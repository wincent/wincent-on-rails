FactoryGirl.define do
  factory :article do
    title { Sham.random }
    body  { Sham.lorem_ipsum }
  end
end
