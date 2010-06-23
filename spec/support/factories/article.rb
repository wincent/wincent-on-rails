require 'factory_girl/syntax/sham'

Sham.article_title do |n|
  if Rails.env == 'development'
    "Random article about #{Sham.random}"
  else
    "Article number #{n}"
  end
end

Factory.define :article do |a|
  a.title { Sham.article_title }
  a.sequence(:body) { |n| "Body #{n}." }
end
