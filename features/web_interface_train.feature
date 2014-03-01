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
  Scenario: Train class for a string
    Given The feedback queue is empty
      And I submit "Test Input" for labeling
    When I am on the training page
      And I enter "test" into the training_class field
      And I press "Submit"
      And I wait for the server
    Then the last entry in the training queue should have class "test"

  @javascript
  Scenario: Train tags for a string
    Given The feedback queue is empty
      And I submit "My name is Inigo Montoya" for labeling
    When I am on the training page
      And I select the training input at 11 and 24
      And I enter "Name" into the training_label field
      And I press "Add"
      And I press "Submit"
      And I wait for the server
    Then the training queue should contain the Inigo Montoya data

  @javascript
  Scenario: Submitting training statement updates feedback queue
    Given The feedback queue is empty
      And I submit "My name is Inigo Montoya" for labeling
    When I am on the training page
      And I tag the training input at 11 and 24 with "Name"
      And I press "Submit"
      And I wait for the server
    Then the feedback queue should be empty
