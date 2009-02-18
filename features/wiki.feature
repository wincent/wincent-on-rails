Feature: accessing the wiki index
  As a user
  I want to view the wiki index
  So that I can get an overview of what is available

  Scenario: the wiki has no article
    Given no articles in the wiki
    When I access the wiki index
    Then I should see "Recently updated"
    And I should see "Top tags"

  Scenario: articles are added to the wiki
    Given no articles in the wiki
    When an article titled "foo" is added to the wiki
    And an article titled "bar" is added to the wiki
    And an article titled "baz" is added to the wiki
    And I access the wiki index
    Then I should see "Recently updated"
    And I should see "foo"
    And I should see "bar"
    And I should see "baz"
