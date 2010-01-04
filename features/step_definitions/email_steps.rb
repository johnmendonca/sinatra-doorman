# Commonly used email steps
#
# The available methods are:
#
# deliveries, all_email
# current_email
# current_email_address
# reset_mailer
# last_email_sent
# inbox, inbox_for
# open_email, open_email_for
# find_email, find_email_for
# email_links
# email_links_matching
#

#
# A couple methods to handle some words in these steps
#

module EmailStepsWordHelpers
  def get_address(word)
    return nil if word == "I" || word == "they"
    word
  end

  def get_amount(word)
    return 0 if word == "no"
    return 1 if word == "a" || word == "an"
    word.to_i
  end
end

World(EmailStepsWordHelpers)

#
# Reset the e-mail queue within a scenario.
#

Given /^(?:a clear email queue|no emails have been sent)$/ do
  reset_mailer
end

#
# Check how many emails have been sent/received
#

Then /^(?:I|they|"([^"]*?)") should have (an|no|\d+) emails?$/ do |person, amount|
  inbox_for(:address => get_address(person)).size.should == get_amount(amount)
end

#
# Accessing email
#

When /^(?:I|they|"([^"]*?)") opens? the email$/ do |person|
  open_email(:address => get_address(person))
end

When /^(?:I|they|"([^"]*?)") opens? the email with subject "([^"]*?)"$/ do |person, subject|
  open_email(:address => get_address(person), :with_subject => subject)
end

When /^(?:I|they|"([^"]*?)") opens? the email with body "([^"]*?)"$/ do |person, body|
  open_email(:address => get_address(person), :with_body => body)
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

Then /^(?:I|they) should see the email is delivered from "([^"]*?)"$/ do |text|
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

When /^(?:I|they) visit "([^"]*?)" in the email$/ do |text|
  visit email_links_matching(text).first
end

When /^(?:I|they) visit the first link in the email$/ do
  visit email_links.first
end

