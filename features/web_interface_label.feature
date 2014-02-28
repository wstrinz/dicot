Feature: Label from web interface
  In order to extract information from my strings
  As a concerned citizen
  I want to label strings through the web interface

  Scenario: Basic labeling
    Given I am on the index page
    When I enter "Where's Will (Monday Afternoon)" into the training input box
      And I submit the form
    Then I should see labeling output
