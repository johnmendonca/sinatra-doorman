@login
Feature: Log in
  In order to get access to protected sections of the site
  A user should be able to log in

  Scenario: User is not signed up
		When I go to the login page
		And I fill in the user form with:
			| login  | password 	|
			| dave	 | dunno 	  |
		And I click the login button
		Then I should be redirected to "/login"
		And I should see an error notice

	Scenario: User is not confirmed
		Given I signed up
		When I go to the login page
		And I fill in the user form with:
			| login | password  |
			| dave  | 5eCuR3z   |
		And I click the login button
		Then I should be redirected to "/login"
		And I should see an error notice
		And I should be logged out

	Scenario: User enters wrong password
		Given I signed up and confirmed my account
		And I am logged out
		When I go to the login page
		And I fill in the user form with:
			| login | password 	|
			| dave	| dunno 	  |
		And I click the login button
		Then I should be redirected to "/login"
		And I should see an error notice
		And I should be logged out

	Scenario: User signs in with username
		Given I signed up and confirmed my account
		And I am logged out
		When I go to the login page
		And I fill in the user form with:
			| login	| password 	|
			| dave 	| 5eCuR3z   |
		And I click the login button
		Then I should be redirected to "/home"
		And I should be logged in

	Scenario: User signs in with email address
		Given I signed up and confirmed my account
		And I am logged out
		When I go to the login page
		And I fill in the user form with:
			| login   	        | password 	|
			| dave@example.com  | 5eCuR3z   |
		And I click the login button
		Then I should be redirected to "/home"
		And I should be logged in

	Scenario: Logged in user tries to login again
		Given I signed up and confirmed my account
		And I am logged in
		When I go to the login page
		Then I should be redirected to "/home"
		And I should be logged in
