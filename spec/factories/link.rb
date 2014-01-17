require_relative '../support/sham.rb'

FactoryGirl.define do
  factory :link do
    uri { "http://#{Sham.random}/#{Sham.random}" }
    permalink { Sham.random }
  end
end
