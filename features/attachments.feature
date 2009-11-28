Feature: attachment uploads

  Scenario: uploading a stand-alone attachment
    Given I am logged in as an admin user
    When I go to /attachments/new
    Then I should see "Upload"
