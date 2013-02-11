require File.expand_path('../factory_girl', File.dirname(__FILE__))

# always return the same passphrase
Sham.passphrase { |n| 'supersecret' }

Sham.user_display_name do |n|
  "#{Sham.random_first_name} #{Sham.random.capitalize} #{Sham.random_last_name}"
end

FactoryGirl.define do
  factory :user do
    display_name { Sham.user_display_name }
    passphrase { Sham.passphrase }
    passphrase_confirmation { Sham.passphrase }
    verified true

    # as a convenience we also set the email pseudo attribute
    # (makes valid_attributes hash more useful in controller tests)
    email Sham.email_address

    # an associated email is not "required" (for validation) but it
    # is still necessary in practice if the record is to be usable
    after(:create) { |user| Email.make! user: user }
  end

  factory :admin_user, :parent => :user do
    superuser true
  end
end
