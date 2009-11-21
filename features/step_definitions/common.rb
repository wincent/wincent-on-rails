When /^I log in as an admin user$/ do
  email = create_email
  user = email.user
  user.superuser = true
  user.save!
  visit login_path
  fill_in 'Email address', :with => email.address
  fill_in 'Passphrase', :with => FixtureReplacement::PASSPHRASE
  click_button 'Log in'
end
