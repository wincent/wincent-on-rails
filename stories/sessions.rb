#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), 'helper')

steps = Spec::Story::StepGroup.new do |define|
  define.given 'a user with email "$email" and passphrase "$passphrase"' do |email, passphrase|
    # since adding the email field the simple FixtureReplacement way doesn't work any more;
    # need to look into how to make it work again
    #create_user :email => email, :passphrase => passphrase, :passphrase_confirmation => passphrase
    user = create_user(:passphrase => passphrase, :passphrase_confirmation => passphrase)
    user.emails.build(:address => email).save
  end

  define.when 'I go to the login form' do
    get '/login'
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
}, :type => RailsStory, :steps => steps do

  Scenario 'logging in successfully' do
    Given 'a user with email "user@example.com" and passphrase "passphrase1000"'
    When 'I go to the login form'
    And 'I fill in the "email" field with "user@example.com"'
    And 'I fill in the "passphrase" field with "passphrase1000"'
    And 'I click the "Log in" button'
    Then 'the page should show "Successfully logged in"'
  end
end
