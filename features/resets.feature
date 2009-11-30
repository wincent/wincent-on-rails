Feature: resetting my passphrase
  As a user
  I want to be able to reset my forgotten passphrase
  So that I can continue to access the site

  @javascript
  Scenario: performing a reset
    Given the following emails:
      | address         |
      | foo@example.com |
    When I go to /resets/new
    And I fill in "Email address" with "foo@example.com"
    And click the "Reset passphrase" button
    Then I should see "an email has been sent to foo@example.com"

  @javascript
  Scenario: hitting the reset limit
    Given the following emails:
      | address         |
      | foo@example.com |
    When I go to /resets/new
    And I fill in "Email address" with "foo@example.com"
    And click the "Reset passphrase" button
    And go to /resets/new
    And fill in "Email address" with "foo@example.com"
    And click the "Reset passphrase" button
    And go to /resets/new
    And fill in "Email address" with "foo@example.com"
    And click the "Reset passphrase" button
    And go to /resets/new
    And fill in "Email address" with "foo@example.com"
    And click the "Reset passphrase" button
    And go to /resets/new
    And fill in "Email address" with "foo@example.com"
    And click the "Reset passphrase" button
    And go to /resets/new
    And fill in "Email address" with "foo@example.com"
    And click the "Reset passphrase" button
    And go to /resets/new
    And fill in "Email address" with "foo@example.com"
    And click the "Reset passphrase" button
    And go to /resets/new
    And fill in "Email address" with "foo@example.com"
    And click the "Reset passphrase" button
    And go to /resets/new
    And fill in "Email address" with "foo@example.com"
    And click the "Reset passphrase" button
    Then I should see "You have exceeded the resets limit"
