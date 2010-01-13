@forgot
Feature: Forgot password
	In order to sign in even if user forgot their password
	A user should be able to reset it

  Scenario: Outsider claims forgotten password
		When I go to the forgot page
		And I fill in the form with:
			| email 			      |
			| sucka@example.com	|
		And I click the reset button
		Then I should be redirected to "/forgot"
		And I should see an error notice

  Scenario: User forgets password
		Given I signed up
		When I go to the forgot page
		And I fill in the form with:
			| email 			      |
			| dave@example.com	|
		And I click the reset button
		Then I should be redirected to "/login"
		And I should see a success notice
		And I should have an email
		And I should see "/reset" in the email body

  Scenario: User forgets and can't confirm new password
		Given I signed up
		And I forgot my password
		When I visit the first link in the email 
		And I fill in the form with:
			| password 	| password_confirmation	|
			| 5eCuR3z	  | securis				        |
		And I click the reset button
		Then I should be redirected to "/reset"
		And I should see an error notice

  Scenario: Confirmed user forgets and updates password
		Given I signed up and confirmed my account
		And I am logged out
		And I forgot my password
		When I visit the first link in the email 
		And I fill in the form with:
			| password 	| password_confirmation	|
			| 5eCuR3z	  | 5eCuR3z	              |
		And I click the reset button
		Then I should be redirected to "/home"
		And I should see a success notice
    And I should be logged in

  Scenario: Unconfirmed user forgets and updates password
		Given I signed up
		And I forgot my password
		When I visit the first link in the email 
		And I fill in the form with:
			| password 	| password_confirmation	|
			| 5eCuR3z	  | 5eCuR3z	              |
		And I click the reset button
		Then I should be redirected to "/home"
		And I should see a success notice
    And I should be logged in
