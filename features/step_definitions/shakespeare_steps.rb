Given(/^I am not logged in$/) do
end

When(/^I open the shakespeare index page$/) do
  visit mdms_path
end

Then(/^I should see index page$/) do
  visit mdms_path
  response.should contain("Shakespeare")
end