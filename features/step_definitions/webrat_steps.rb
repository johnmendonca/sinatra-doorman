Given /^that the following users exist$/ do |table|
  table.hashes.each do |params|
    user = Sinatra::Bouncer::User.new(params)
    user.confirm_email!
    user.save!
  end
end

When /^I go to the (.*) page$/ do |path|
  visit "/#{path}"
end

When /^I fill the (.*) form with:$/ do |type, table|
  table.hashes.each do |hash|
    hash.each_pair do |key, value|
      fill_in "#{type}[#{key}]", :with => value
    end
  end
end

When /^I fill in the form with:$/ do |table|
  # table is a Cucumber::Ast::Table
  pending # express the regexp above with the code you wish you had
end

When /^I click the (.*) button$/ do |label|
  click_button(label)
end

Then /^I should be redirected to root$/ do 
  URI.parse(current_url).path.should == "/"
end

Then /^I should be redirected to the (.*) page$/ do |path|
  URI.parse(current_url).path.should == "/#{path}"
end

Then /^I should be redirected to "([^\"]*)"$/ do |path|
  URI.parse(current_url).path.should == path
end

Then /^I should see error messages$/ do
  last_response.should have_selector 'div#flash-error'
end

Then /^I should see an error notice$/ do
  last_response.should have_selector 'div#flash-error'
end

Then /^I should see a success notice$/ do
  last_response.should have_selector 'div#flash-notice'
end

Given /^I signed up with:$/ do |table|
		When "I go to the signup page"
		And "I fill the user form with:", table 
		And "I click the signup button"
		Then "I should be redirected to root"
		And "I should see a success notice"
		And 'I should have an email'
end

Given /^I signed up$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^I signed up and confirmed my account$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^I forgot my password$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^I am logged in$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^I am logged out$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^I am remembered$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^I am forgotten$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I log out$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should be logged out$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should be logged in$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should be remembered$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should be forgotten$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I check "([^\"]*)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Given /^I have started a new browser session$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I fill the user form with my information$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I fill in the form with my information$/ do
  pending # express the regexp above with the code you wish you had
end

