@remember
Feature: Remember me
	So that one need not log in on every visit
	A user should be able to be remembered

	Scenario: User logs in asking to be remembered
		Given I signed up and confirmed my account
		And I am logged out
		And I am forgotten
		When I go to the login page
		And I fill in the form with my information
		And I check "Remember Me"
		And I click the submit button
		Then I should be redirected to "/home"
		And I should be logged in
		And I should be remembered

	Scenario: Remembered user returns
		Given I signed up and confirmed my account
		And I am remembered
		And I have started a new browser session
		When I go to the login page
		Then I should be redirected to "/home"
		And I should be logged in
		And I should be remembered

	Scenario: Remembered user logs out
		Given I signed up and confirmed my account
		And I am logged in
		And I am remembered
		When I log out
		Then I should be redirected to "/login"
		And I should see a success notice
		And I should be logged out
		And I should be forgotten
