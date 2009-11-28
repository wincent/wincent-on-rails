Feature: dynamic relative dates
  As a user
  I prefer to see friendly relative dates like "1 day ago"
  So that I can easily tell how recent content is

  @javascript
  Scenario: viewing the wiki index (with JavaScript)
    Given the following articles:
      | created_at |
      | 5.days.ago |
    When I go to /wiki
    Then I should see "5 days ago"

  Scenario: viewing the wiki index (without JavaScript)
    Given the following articles:
      | created_at |
      | 5.days.ago |
    When I go to /wiki
    Then I should not see "days ago"
