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

When(/^I check it$/) do
  page.evaluate_script('addTraining()')
  puts page.evaluate_script('$("#output").text()')
end

When(/^I enter "(.*?)" into the (.*?) field$/) do |string, field|
  fill_in "#{field}", with: string
end

Then(/^the last entry in the training queue should have class "(.*?)"$/) do |klass|
  Dicot::Classify.training_queue.last.last.should == klass
end

When(/^I select the training input at (\d+) and (\d+)$/) do |start, ending|
  #str = find("#training_input").to_s
  page.evaluate_script("selStart = #{start}; selEnd = #{ending} ;")
end

Then(/^the training queue should contain the Inigo Montoya data$/) do
  tokens = %w{My name is Inigo Montoya}
  tags = %w{O O O B-Name I-Name}
  Dicot::Trainer.training_buffer.last.should == tokens.zip(tags)
end
