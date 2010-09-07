require File.expand_path('../factory_girl', File.dirname(__FILE__))

# always return the same passphrase
Sham.passphrase { |n| 'supersecret' }

Sham.user_display_name do |n|
  "#{Sham.random_first_name} #{Sham.random.capitalize} #{Sham.random_last_name}"
end

Factory.define :user do |u|
  u.display_name { Sham.user_display_name }
  u.passphrase { Sham.passphrase }
  u.passphrase_confirmation { Sham.passphrase }
  u.verified true

  # as a convenience we also set the email pseudo attribute
  # (makes valid_attributes hash more useful in controller tests)
  u.email Sham.email_address

  # an associated email is not "required" (for validation) but it
  # is still necessary in practice if the record is to be usable
  u.after_create { |user| Email.make! :user => user  }
end

Factory.define :admin_user, :parent => :user do |u|
  u.superuser true
end
