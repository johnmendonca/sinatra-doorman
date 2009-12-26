# Commonly used email steps
#
# The provided methods are:
#
# all_emails
# last_email_sent
# reset_mailer
# current_email_address
# current_email
# inbox, inbox_for
# open_email, open_email_for
# find_email, find_email_for
# email_links
# email_links_matching
#
# General form for email scenarios are:
#   - clear the email queue
#   - execute steps that sends an email
#   - check the user received an/no/[0-9] emails
#   - open the email
#   - inspect the email contents
#   - interact with the email (e.g. click links)
#
# The Cucumber steps below are setup in this order.

#
# Reset the e-mail queue within a scenario.
# This is done automatically before each scenario.
#

Given /^(?:a clear email queue|no emails have been sent)$/ do
  reset_mailer
end

#
# Check how many emails have been sent/received
#

Then /^(?:I|they|"([^"]*?)") should have (an|no|\d+) emails?$/ do |address, amount|
  inbox_for(address).size.should == parse_email_count(amount)
end

#
# Accessing emails
#

When /^(?:I|they|"([^"]*?)") opens? the email with subject "([^"]*?)"$/ do |address, subject|
  open_email(address, :with_subject => subject)
end

When /^(?:I|they|"([^"]*?)") opens? the email with text "([^"]*?)"$/ do |address, text|
  open_email(address, :with_text => text)
end

#
# Inspect the Email Contents
#

Then /^(?:I|they) should see "([^"]*?)" in the email subject$/ do |text|
  current_email.subject.should include(text)
end

Then /^(?:I|they) should see \/([^"]*?)\/ in the email subject$/ do |text|
  current_email.subject.should =~ Regexp.new(text)
end

Then /^(?:I|they) should see "([^"]*?)" in the email body$/ do |text|
  current_email.body.should include(text)
end

Then /^(?:I|they) should see \/([^"]*?)\/ in the email body$/ do |text|
  current_email.body.should =~ Regexp.new(text)
end

Then /^(?:I|they) should see the email delivered from "([^"]*?)"$/ do |text|
  current_email.from.should include(text)
end

Then /^(?:I|they) should see "([^\"]*)" in the email "([^"]*?)" header$/ do |text, name|
  current_email.header[name].should include(text)
end

Then /^(?:I|they) should see \/([^\"]*)\/ in the email "([^"]*?)" header$/ do |text, name|
  current_email.header[name].should include(Regexp.new(text))
end

#
# Interact with Email Contents
#

When /^(?:I|they) follow "([^"]*?)" in the email$/ do |text|
  visit email_links_matching(text).first
end

When /^(?:I|they) click the first link in the email$/ do
  visit email_links.first
end

