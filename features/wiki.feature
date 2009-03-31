Feature: accessing the wiki index
  As a user
  I want to view the wiki index
  So that I can get an overview of what is available

  Scenario: the wiki has no articles
    Given no articles in the wiki
    When I go to the wiki index
    Then I should see "Recently updated"
    And I should see "Top tags"

  Scenario: the wiki has various articles
    Given no articles in the wiki
    And an article titled "foo"
    And an article titled "bar"
    And an article titled "baz"
    When I go to the wiki index
    Then I should see "Recently updated"
    And I should see "foo"
    And I should see "bar"
    And I should see "baz"
