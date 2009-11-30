Feature: annotated changes to issue metadata
  As a user
  I want changes to issue metadata to be annotated as comments
  So that I can see how the issue has changed over time

  Scenario: I change an issue summary
    Given an issue with summary "foo"
    When I log in as an admin user
    And I edit the issue with summary "foo"
    And fill in "Summary" with "bar"
    And click the "Save changes" button
    Then I should see "Summary changed"
