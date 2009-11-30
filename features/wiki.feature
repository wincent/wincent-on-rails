Feature: accessing the wiki index
  As a user
  I want to view the wiki index
  So that I can get an overview of what is available

  Scenario: the wiki has no articles
    Given no articles in the wiki
    When I go to /wiki
    Then I should see "Recently updated"
    And should see "Top tags"

  Scenario: the wiki has various articles
    Given an article titled "foo"
    And an article titled "bar"
    And an article titled "baz"
    When I go to /wiki
    Then I should see "Recently updated"
    And should see "foo"
    And should see "bar"
    And should see "baz"
