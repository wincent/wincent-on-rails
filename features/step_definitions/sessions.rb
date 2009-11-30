When /^(?:I |)log in as an admin user$/ do
  email = create_email
  user = email.user
  user.superuser = true
  user.save!
  visit login_path
  fill_in 'Email address', :with => email.address
  fill_in 'Passphrase', :with => FixtureReplacement::PASSPHRASE
  click_button 'Log in'
end

When /^(?:I am |)logged in as an admin user$/ do
  When 'I log in as an admin user'
end

When /^(?:I |)log in$/ do
  email = create_email
  user = email.user
  user.save!
  visit login_path
  fill_in 'Email address', :with => email.address
  fill_in 'Passphrase', :with => FixtureReplacement::PASSPHRASE
  click_button 'Log in'
end

When /^(?:I am |)logged in$/ do
  When 'I log in'
end

When /^(?:I |)log out$/ do
  When 'I go to /logout'
end

When /^(?:I am |)logged out$/ do
  When 'I log out'
  And 'I go to /' # get rid of "Can't log out" flash, if present
end

When /^(?:I am |)not logged in$/ do
  When 'I am logged out'
end
