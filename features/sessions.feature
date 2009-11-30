Feature: logging in to the site
  As a user
  I want to be able to log in to the site
  So that I can own my own content

  @javascript
  Scenario: logging in and seeing a flash
    Given I am logged out
    When I log in
    Then I should see "Successfully logged in"

  @javascript
  Scenario: logging out and seeing a flash
    Given I am logged in
    When I log out
    Then I should see "You have logged out successfully"

  @javascript
  Scenario: trying to log out when not logged in and seeing a flash
    Given I am logged out
    When I log out
    # full message is "Can't log out (weren't logged in)"
    # but Capybara chokes on single quotes
    # see: http://github.com/jnicklas/capybara/issues/#issue/7
    Then I should see "t log out (weren"

  @javascript
  Scenario: dynamic "log in"/"log out" links (when logged in)
    Given I am logged in
    Then I should see "log out"
    And should not see "log in"

  @javascript
  Scenario: dynamic "log in"/"log out" links (when logged out)
    Given I am logged out
    Then I should see "log in"
    And should not see "log out"

  Scenario: dynamic "log in"/"log out" links (with no JavaScript)
    Given I go to /
    Then I should see "log in"
    And should see "log out"
