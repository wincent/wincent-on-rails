#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), 'helper')

steps = Spec::Story::StepGroup.new do |define|
  define.given 'a logged-in user' do
    passphrase = String.random
    email = "#{String.random}@#{String.random}.com"
    user = create_user :passphrase => passphrase, :passphrase_confirmation => passphrase
    create_email :address => email, :user => user
    get '/login'
    fills_in 'email', :with => email
    fills_in 'passphrase', :with => passphrase
    clicks_button 'Log in'
  end

  define.given 'an anonymous user' do
    get_via_redirect '/logout'
  end

  define.given 'a user with email "$email" and passphrase "$passphrase"' do |email, passphrase|
    user = create_user :passphrase => passphrase, :passphrase_confirmation => passphrase
    create_email :address => email, :user => user
  end

  define.when 'I go to the login form' do
    get '/login'
  end

  define.when 'I logout' do
    get_via_redirect '/logout'
  end

  define.when 'I fill in the "$field" field with "$text"' do |field, text|
    fills_in field, :with => text
  end

  define.when 'I click the "$button" button' do |button|
    clicks_button button
  end

  define.then 'the page should show "$text"' do |text|
    response.should have_text(/#{text}/)
  end
end

Story 'logging in', %{
  As an account holder
  I want to log in
  So that I can take ownership of my submissions to the site
}, :type => RailsStory, :steps_for => steps do

  Scenario 'logging in successfully' do
    Given 'a user with email "user@example.com" and passphrase "passphrase1000"'
    When 'I go to the login form'
    And 'I fill in the "email" field with "user@example.com"'
    And 'I fill in the "passphrase" field with "passphrase1000"'
    And 'I click the "Log in" button'
    Then 'the page should show "Successfully logged in"'
  end

  Scenario 'logging in with a bad passphrase' do
    Given 'a user with email "user@example.com" and passphrase "passphrase1000"'
    When 'I go to the login form'
    And 'I fill in the "email" field with "user@example.com"'
    And 'I fill in the "passphrase" field with "whoops!"'
    And 'I click the "Log in" button'
    Then 'the page should show "Invalid email or passphrase"'
  end

  Scenario 'logging in with a bad email' do
    Given 'a user with email "user@example.com" and passphrase "passphrase1000"'
    When 'I go to the login form'
    And 'I fill in the "email" field with "bad@bad.com"'
    And 'I fill in the "passphrase" field with "passphrase1000"'
    And 'I click the "Log in" button'
    Then 'the page should show "Invalid email or passphrase"'
  end
end

Story 'logging out', %{
  As an account holder
  I want to log out
  So that nobody using my machine can impersonate me
}, :type => RailsStory, :steps_for => steps do

  Scenario 'logging out when logged-in' do
    Given 'a logged-in user'
    When 'I logout'
    Then 'the page should show "You have logged out successfully"'
  end

  Scenario 'logging out when not logged-in' do
    Given 'an anonymous user'
    When 'I logout'
    Then 'the page should show "Can\'t log out \(weren\'t logged in\)"'
  end
end
