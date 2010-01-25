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
  Then 'I should be redirected to "/login"'
  And "I should see a success notice"
end

Given /^I forgot my password$/ do
  When 'I go to the forgot page'
  And 'I fill in the user form with:', table(%{
    | login        			|
    | dave@example.com	|
  })
  And 'I click the forgot button'
  Then 'I should be redirected to "/login"'
  And 'I should see a success notice'
  And 'I should have 2 emails'
  And 'I should see "/reset" in the email body'
end

Given /^I am logged in$/ do
  unless last_request.env['warden'].authenticated?
    When 'I go to the login page'
    And 'I fill in the user form with:', table(%{
      | login   | password 	|
      | dave    | 5eCuR3z   |
    })
    And 'I click the login button'
  end
end

When /^I log in$/ do
  Given 'I am logged in'
end

Given /^I am logged out$/ do
  visit '/logout'
end

Given /^I am logged in and remembered$/ do
  When 'I go to the login page'
  And 'I fill in the user form with:', table(%{
    | login   | password 	|
    | dave    | 5eCuR3z   |
  })
  And 'I check "user[remember_me]"'
  And 'I click the login button'
  Then 'I should be redirected to "/home"'
  And 'I should be logged in'
  And 'I should be remembered'
end

When /^I log out$/ do
  visit '/logout'
end

Then /^I should be logged out$/ do
  last_request.env['warden'].authenticated?.should == false
end

Then /^I should be logged in$/ do
  last_request.env['warden'].authenticated?.should == true
end

Then /^I should be remembered$/ do
  last_request.env['rack.cookies'][Sinatra::Bouncer::COOKIE_KEY].should_not be_nil
end

Then /^I should be forgotten$/ do
  last_request.env['rack.cookies'][Sinatra::Bouncer::COOKIE_KEY].should be_nil
end

When /^I check "([^\"]*)"$/ do |label|
  check label
end

Given /^I have started a new session$/ do
  last_request.env['rack.session'].clear
end
