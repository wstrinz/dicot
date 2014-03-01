Feature: Label from web interface
  In order to make my instance more intelligent
  As a mad scientist
  I want to address the feedback queue through the web interface

  @javascript
  Scenario: View feedback queue
    Given There is feedback in the queue
    When I am on the training page
    Then I should see the head of the feedback queue

  @javascript
  Scenario: Train on a string
    Given The feedback queue is empty
      And I submit "Test Input" for labeling
      And I am on the training page
    When I enter "test" into the training_class field
      And I press "Submit"
    Then the last entry in the training queue should have class "test"
