Feature: Label from web interface
  In order to extract information from my strings
  As a concerned citizen
  I want to label strings through the web interface

  @javascript
  Scenario: Train a sample string
    Given There is feedback in the queue
    When I am on the training page
    Then I should see the head of the feedback queue
