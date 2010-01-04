@forgot
Feature: Forgot password
	In order to sign in even if user forgot their password
	A user should be able to reset it

    Scenario: Outsider claims forgotten password
		When I go to the forgot page
		And I fill in the form with:
			| email 			|
			| sucka@example.com	|
		And I click the reset button
		Then I should be redirected to "/forgot"
		And I should see an error notice

    Scenario: User forgets
		Given I signed up
		When I go to the forgot page
		And I fill in the form with:
			| email 			|
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
			| 5eCuR3x	| securis				|
		And I click the reset button
		Then I should be redirected to "/login"
		And I should see an error notice

    Scenario: Confirmed user forgets and updates password
		Given I signed up and confirmed my account
		And I am logged out
		And I forgot my password
		When I visit the first link in the email 
		And I fill in the form with:
			| password 	| password_confirmation	|
			| 5eCuR3x	| securis				|
		And I click the reset button

	@wip
    Scenario: Unconfirmed user forgets and updates password
      Given I signed up with "email@person.com/password"
      When I follow the password reset link sent to "email@person.com"
      And I update my password with "newpassword/newpassword"
      Then I should be signed in
      When I sign out
      Then I should be signed out
      And I sign in as "email@person.com/newpassword"
      Then I should be signed in

