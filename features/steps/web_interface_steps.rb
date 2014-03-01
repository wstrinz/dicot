Given(/^I am on the index page$/) do
  visit "/"
end

When(/^I enter "(.*?)" into the training input box$/) do |input|
  fill_in("label_input", with: input)
end

When(/^I press "(.*?)"$/) do |button|
  click_button(button)
end

Then(/^I should see labeling output$/) do
  label_response =
  {
      string: "Where's Will (Monday Afternoon)",
      tags:
      [
        {string: "Will", tag:"Name", start:8, end:11},
        {string: "Monday Afternoon", tag:"TS", start:14, end:29}
      ],
      class:""
  }
  expect(page).to have_content label_response.to_json
end
