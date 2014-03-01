Given(/^There is feedback in the queue$/) do
  Dicot.label("Where's Will (Monday Afternoon)", true)
end

Then(/^I should see the head of the feedback queue$/) do
  expect(find("#training_input")).to have_content "Where's Will (Monday Afternoon)"
end

Given(/^The feedback queue is empty$/) do
  Dicot::Trainer.feedback_queue.clear
end

Given(/^I submit "(.*?)" for labeling$/) do |string|
  Dicot.label(string, true)
end

When(/^I enter "(.*?)" into the (.*?) field$/) do |string, field|
  fill_in "#{field}", with: string
end

Then(/^the last entry in the training queue should have class "(.*?)"$/) do |klass|
  Dicot::Classify.training_queue.last.last.should == klass
end
