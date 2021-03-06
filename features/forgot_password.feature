@forgot
Feature: Forgot password
	In order to sign in even if user forgot their password
	A user should be able to reset it

	Scenario: Outsider claims forgotten password
		When I go to the forgot page
		And I fill in the user form with:
			| login				|
			| sucka@example.com	|
		And I click the forgot button
		Then I should be redirected to "/forgot"
		And I should see an error notice

	Scenario: User forgets password
		Given I signed up
		When I go to the forgot page
		And I fill in the user form with:
			| login				|
			| dave@example.com	|
		And I click the forgot button
		Then I should be redirected to "/login"
		And I should see a success notice
		And I should have 2 emails
		And I should see "/reset" in the email body

	Scenario: User forgets and can't confirm new password
		Given I signed up
		And I forgot my password
		When I visit the first link in the email 
		And I fill in the user form with:
			| password 	| password_confirmation	|
			| 5eCuR3z	| securis				|
		And I click the reset button
		Then I should be redirected to "/reset"
		And I should see an error notice

	Scenario: Confirmed user forgets and updates password
		Given I signed up and confirmed my account
		And I am logged out
		And I forgot my password
		When I visit the first link in the email 
		And I fill in the user form with:
			| password 	| password_confirmation	|
			| 5eCuR3z	| 5eCuR3z	            |
		And I click the reset button
		Then I should be redirected to "/home"
		And I should see a success notice
		And I should be logged in

	Scenario: Unconfirmed user forgets and updates password
		Given I signed up
		And I forgot my password
		When I visit the first link in the email 
		And I fill in the user form with:
			| password 	| password_confirmation	|
			| 5eCuR3z	| 5eCuR3z	            |
		And I click the reset button
		Then I should be redirected to "/home"
		And I should see a success notice
		And I should be logged in

		# Now the user should be confirmed
		When I log out
		And I log in
		Then I should be redirected to "/home"
		And I should be logged in

	Scenario: User forgets, then remembers and logs in
		Given I signed up and confirmed my account
		And I am logged out
		And I forgot my password
        # Then I remember somehow
		When I go to the login page
		And I fill in the user form with:
			| login	| password 	|
			| dave 	| 5eCuR3z   |
		And I click the login button
		Then I should be redirected to "/home"
		And I should be logged in

		# After logging in, reset link should not work
		When I log out
		And I visit the first link in the email 
		Then I should be redirected to "/login"
		And I should see an error notice
