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

When /^I go to "(.*)"$/ do |path|
  visit path
end

When /^I fill in the (.*) form with:$/ do |type, table|
  table.hashes.each do |hash|
    hash.each_pair do |key, value|
      fill_in "#{type}[#{key}]", :with => value
    end
  end
end

When /^I fill in the form with:$/ do |table|
  table.hashes.each do |hash|
    hash.each_pair do |key, value|
      fill_in key, :with => value
    end
  end
end

When /^I click the (.*) button$/ do |label|
  click_button(label)
end

Then /^I should be redirected to root$/ do 
  URI.parse(current_url).path.should == "/"
end

Then /^I should be redirected to the (.*) page$/ do |path|
  URI.parse(current_url).path.should include("/#{path}")
end

Then /^I should be redirected to "([^\"]*)"$/ do |path|
  URI.parse(current_url).path.should include(path)
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
  And "I fill in the user form with:", table 
  And "I click the signup button"
  Then "I should be redirected to root"
  And "I should see a success notice"
  And 'I should have an email'
end

Given /^I signed up$/ do
  When "I go to the signup page"
  And "I fill in the user form with:", table(%{
    | username | email            | password | password_confirmation   |
    | dave     | dave@example.com | 5eCuR3z  | 5eCuR3z                 |
  })
  And "I click the signup button"
  Then "I should be redirected to root"
  And "I should see a success notice"
  And 'I should have an email'
end

Given /^I signed up and confirmed my account$/ do
  Given "I signed up"
  When "I visit the first link in the email"
  And "I fill in the user form with:", table(%{
    | username 	| password 	|
    | dave		| 5eCuR3z	|
  })
  And "I click the confirm button"
  Then 'I should be redirected to "/home"'
  And "I should see a success notice"
  And 'I should be logged in'
end

Given /^I forgot my password$/ do
  Given 'I signed up'
  When 'I go to the forgot page'
  And 'I fill in the form with:', table(%{
    | email 			|
    | dave@example.com	|
  })
  And 'I click the reset button'
  Then 'I should be redirected to "/login"'
  And 'I should see a success notice'
  And 'I should have an email'
  And 'I should see "/reset" in the email body'
end

Given /^I am logged in$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^I am logged out$/ do
  visit '/logout'
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
  last_request.env['warden'].user.should == nil
end

Then /^I should be logged in$/ do
  last_request.env['warden'].user.username.should == 'dave'
  last_request.env['warden'].user.email.should == 'dave@example.com'
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
