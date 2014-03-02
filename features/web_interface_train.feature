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

  @javascript
  Scenario: Retrain using submitted data
    Given The feedback queue is empty
      And I am on the index page
      And I enter "What color is the sun?" into the training input box
      And I press "Label"
    Then I should see the wrong tags and class for the sun question
    When I visit "train"
      And I tag the training input at 5 and 10 with "Predicate"
      And I tag the training input at 18 and 21 with "Subject"
      And I enter "Question" into the training_class field
      And I press "Submit"
      And I wait for the server
      And I visit "retrain"
      And I visit ""
      And I enter "What color is the sun?" into the training input box
      And I press "Label"
    Then I should see tags and features for the color of the sun question

  @javascript
  Scenario: Clears input fields after submitting training data
    Given The feedback queue is empty
      And I submit "My name is Inigo Montoya" for labeling
    When I am on the training page
      And I tag the training input at 11 and 24 with "Name"
      And I press "Submit"
      And I wait for the server
    Then the field "training_input" should be blank
      And the field "training_class" should be blank
      And the field "training_label" should be blank
      And the section "output" should be blank

  @javascript
  Scenario: Scrolls through feedback queue
    Given There are 3 things in the feedback queue
    When I am on the training page
    Then the feedback counter should read "1 / 3"
      And I should see feedback item 1
    When I enter "test" into the training_class field
      And I press "Submit"
      And I wait for the server
    Then the feedback counter should read "1 / 2"
      And I should see feedback item 2
    When I press "Next"
    Then the feedback counter should read "2 / 2"
      And I should see feedback item 3
    When I press "Prev"
    Then the feedback counter should read "1 / 2"
      And I should see feedback item 2
    When I press "Skip"
    Then the feedback counter should read "1 / 1"
      And I should see feedback item 3
    When I press "Confirm"
    Then the feedback counter should read "0 / 0"
      And I should see no feedback items
