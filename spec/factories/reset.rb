FactoryGirl.define do
  factory :reset do
    association :email

    after(:build) do |reset|
      reset.email_address = reset.email ? reset.email.address : nil
    end

    after(:create) do |reset|
      # work around Factory Girl quirks; `on: :update` validations are running
      # when we call `Reset.make!`, because by the time we check for validity,
      # the record has been saved, at which point the `on: :update` validations
      # are the ones that run
      reset.email_address           = reset.email.address
      reset.passphrase              = 'supersecret'
      reset.passphrase_confirmation = 'supersecret'
    end
  end
end
