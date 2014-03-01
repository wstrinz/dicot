When(/^I enter "(.*?)" into the training input box$/) do |input|
  fill_in("label_input", with: input)
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
      class:"Out of Office"
  }
  expect(page).to have_content label_response.to_json
end

Then(/^I should see some but not all tags$/) do
  label_response =
  {
    string: "Where's Bill going to be Thursday Afternoon",
    tags:[
      {string: "Bill", tag: "Name", start: 8, end: 11}
    ],
    class:"Out of Office"
  }
  expect(page).to have_content label_response.to_json
end

Then(/^I should see the TS tag as well$/) do
  label_response =
  {
    string: "Where's Bill going to be Thursday Afternoon",
    tags:[
      {string: "Bill", tag: "Name", start: 8, end:11},
      {string: "Thursday Afternoon", tag: "TS",start: 25, end: 42}
    ],
    class:"Out of Office"
  }
  expect(page).to have_content label_response.to_json
end
