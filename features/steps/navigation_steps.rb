Given(/^I am on the index page$/) do
  visit "/"
end

When(/^I am on the training page$/) do
  visit "/train"
end

When(/^I press "(.*?)"$/) do |button|
  click_button(button)
end
