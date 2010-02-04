@remember
Feature: Remember me
  So that one need not log in on every visit
  A user should be able to be remembered

	Scenario: User logs in asking to be remembered
		Given I signed up and confirmed my account
		And I am logged out
		When I go to the login page
		And I fill in the user form with:
			| login	| password 	|
			| dave 	| 5eCuR3z   |
		And I check "user[remember_me]"
		And I click the login button
		Then I should be redirected to "/home"
		And I should be logged in
		And I should be remembered

	Scenario: Remembered user returns
		Given I signed up and confirmed my account
		And I am logged in and remembered
		And I have started a new session
		When I go to the login page
    Then I should be redirected to "/home"
		And I should be logged in
		And I should be remembered

	Scenario: Remembered user logs out
		Given I signed up and confirmed my account
		And I am logged in and remembered
		When I log out
		Then I should be redirected to "/login"
		And I should see a success notice
		And I should be logged out
		And I should be forgotten
