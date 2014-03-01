Given(/^I am on the index page$/) do
  visit "/"
end

When(/^I am on the training page$/) do
  visit "/train"
end

When(/^I visit "(.*?)"$/) do |place|
  visit "/#{place}"
end

When(/^I press "(.*?)"$/) do |button|
  click_button(button)
end

When(/^I wait for the server$/) do
  sleep(0.05)
end
