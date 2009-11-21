Feature: logging in to the site
  As a usr
  I want to be able to log in to the site
  So that I can own my own content

  @javascript
  Scenario:
    Given I log in as an admin user
    Then I should see "Successfully logged in"
