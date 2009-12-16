Given /^that the following users exist$/ do |table|
  table.hashes.each do |params|
    user = Sinatra::Bouncer::User.new(params)
    user.confirm_email!
    user.save
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

When /^I click the (.*) button$/ do |label|
  click_button(label)
end

Then /^I should be redirected to the (.*) page$/ do |path|
  #last_response.headers['Location'].should contain("/#{path}")
end

Then /^I should see error messages$/ do
  puts Sinatra::Application.environment
  last_response.should have_selector 'div#flash-error'
end

Then /^good things happen$/ do
  pending # express the regexp above with the code you wish you had
end

