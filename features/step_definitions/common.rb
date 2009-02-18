When /^I am logged in as an admin user$/ do
  address     = "#{String.random}@example.com"
  passphrase  = String.random
  email       = create_email :address => address, :verified => true
  create_user :email => email,
              :passphrase => passphrase,
              :passphrase_confirmation => passphrase,
              :superuser => true,
              :verified => true
  visit login_path
  fill_in 'email', address
  fill_in 'passphrase', passphrase
  click_button 'Log in'
end
