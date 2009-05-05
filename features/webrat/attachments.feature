Feature: attachment uploads

  Scenario: uploading a stand-alone attachment
    When I go to /attachments/new
    Then I should see "Upload"
