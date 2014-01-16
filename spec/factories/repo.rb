FactoryGirl.define do
  factory :repo do |r|
    name { Sham.random }
    permalink { Sham.random }
    path { GitSpecHelpers.scratch_repo }
    public { true } # defaults to false, but true is more useful for testing
  end
end
