Given /^that the following users exist$/ do |table|
  table.hashes.each do |params|
    user = Sinatra::Bouncer::User.new(params)
    user.confirmed = true
    user.save!
  end
end

When /^I go to the (.*) page$/ do |path|
  visit "/#{path}"
end

When /^I fill the form with:$/ do |table|
  table.hashes.each do |input|
    input.each do |i|
      fill_in i[0], :with => i[1]
    end
  end
end

When /^I click the (.*) button$/ do |label|
  click_button(label)
end

Then /^good things happen$/ do
  pending # express the regexp above with the code you wish you had
end

