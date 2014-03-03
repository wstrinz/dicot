Given(/^There is feedback in the queue$/) do
  Dicot.label("Where's Will (Monday Afternoon)", true)
end

Then(/^I should see the head of the feedback queue$/) do
  expect(find("#training_input").value).to eq "Where's Will (Monday Afternoon)"
end

Given(/^The feedback queue is empty$/) do
  Dicot::CRF.feedback_queue.clear
end

Given(/^I submit "(.*?)" for labeling$/) do |string|
  Dicot.label(string, true)
end

When(/^I check it$/) do
  page.evaluate_script('addTraining()')
  puts page.evaluate_script('$("#output").text()')
end

When(/^I remove the label at index (\d+)$/) do |index|
  page.evaluate_script('removeTag(' + index + ')')
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

When(/^I tag the training input at (\d+) and (\d+) with "(.*?)"$/) do |start, ending, tag|
  step "I select the training input at #{start} and #{ending}"
  step "I enter \"#{tag}\" into the training_label field"
  step 'I press "Add"'
end

Then(/^the training queue should contain the Inigo Montoya data$/) do
  tokens = %w{My name is Inigo Montoya}
  tags = %w{O O O B-Name I-Name}
  Dicot::CRF.training_queue.last.should == tokens.zip(tags)
end

Then(/^the feedback queue should be empty$/) do
  expect(Dicot::CRF.feedback_queue).to eq []
end

Then(/^the field "(.*?)" should be blank$/) do |field|
  expect(find("##{field}").value).to eq ""
end

Then(/^the section "(.*?)" should be blank$/) do |section|
  expect(find("##{section}").text).to eq ""
end

Given(/^There are 3 things in the feedback queue$/) do
  @feedback_items = {
    "1" => Dicot.label("This is a thing"),
    "2" => Dicot.label("Where's Will? (Monday Tuesday)"),
    "3" => Dicot.label("Hello computer")
  }
end

Then(/^the feedback counter should read "(.*?)"$/) do |count_string|
  expect(find("#feedback-count").text).to eq count_string
end

Then(/^I should see feedback item (\d+)$/) do |item_id|
  item = @feedback_items[item_id]
  expect(find("#training_input").value).to eq item[:string]
  expect(find("#training_class").value).to eq item[:class]
  item[:tags].each do |tag|
    str = "(#{tag[:start]}, #{tag[:end]}): #{tag[:string]} - #{tag[:tag]}"
    expect(find("#output")).to have_content str
  end
end

Then(/^I should see no feedback items$/) do
  step 'the field "training_input" should be blank'
  step 'the field "training_class" should be blank'
  step 'the field "training_label" should be blank'
  step 'the section "output" should be blank'
end
