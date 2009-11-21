Feature: attachment uploads

  Scenario: uploading a stand-alone attachment
    When I log in as an admin user
    And I go to /attachments/new
    Then I should see "Upload"
