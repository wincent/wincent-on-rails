FactoryGirl.define do
  factory :product do
    # required attributes
    name { Sham.random }
    permalink { Sham.random }

    # useful defaults
    hide_from_front_page false
  end
end
