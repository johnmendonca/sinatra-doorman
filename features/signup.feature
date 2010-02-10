@signup
Feature: Sign up
  In order to use most of the features of the site
  A user should be able to sign up

  User info used by default when ambiguous:
			| username | email            | password | password_confirmation   |
			| dave     | dave@example.com | 5eCuR3z  | 5eCuR3z                 |

	Scenario Outline: User inputs invalid signup information
		Given that the following users exist
			| username | email            |
			| john     | john@example.com |
		When I go to the signup page
		And I fill in the user form with:
			| username   | email   | password   | password_confirmation   |
			| <username> | <email> | <password> | <password_confirmation> |
		And I click the signup button
		Then I should be redirected to the signup page
		And I should see error messages

		Examples:
			| username | email            | password | password_confirmation |
			|          | guy@example.com  | aWeSoMeG | aWeSoMeG              |
			| guy      |                  | aWeSoMeG | aWeSoMeG              |
			| guy      | guy@example.com  |          | aWeSoMeG              |
			| guy      | guy@example.com  | aWeSoMeG |                       |
			| guy      | example.com      | aWeSoMeG | aWeSoMeG              |
			| john     | guy@example.com  | aWeSoMeG | aWeSoMeG              |
			| guy      | john@example.com | aWeSoMeG | aWeSoMeG              |
			| guy      | guy@example.com  | aWeSoMeG | radicall              |
			| guy@home | guy@example.com  | aWeSoMeG | aWeSoMeG              |

	Scenario: User supplies valid, untaken signup information
		Given that the following users exist
			| username | email            |
			| john     | john@example.com |
		When I go to the signup page
		And I fill in the user form with:
			| username | email            | password | password_confirmation   |
			| dave     | dave@example.com | 5eCuR3z  | 5eCuR3z                 |
		And I click the signup button
		Then I should be redirected to root
		And I should see a success notice
		And I should have an email
		And I should see "/confirm" in the email body

	Scenario: User confirms account
		Given I signed up with:
			| username | email            | password | password_confirmation   |
			| dave     | dave@example.com | 5eCuR3z  | 5eCuR3z                 |
		When I visit the first link in the email
		Then I should be redirected to "/login"
		And I should see a success notice

	Scenario: Unregistered user tries to confirm
		When I go to the confirm page
		Then I should be redirected to "/"
		And I should see an error notice

		When I go to "/confirm/34532faketoken"
		Then I should be redirected to "/login"
		And I should see an error notice

	Scenario: Signed in user clicks confirmation link again
		Given I signed up and confirmed my account
		And I am logged in
		When I visit the first link in the email
		Then I should be redirected to "/home"

	Scenario: Signed out user clicks confirmation link again
		Given I signed up and confirmed my account
		And I am logged out
		When I visit the first link in the email
		Then I should be redirected to "/login"
		And I should see an error notice

	Scenario: Signed in user tries to signup
		Given I signed up and confirmed my account
		And I am logged in
		When I go to the signup page
		Then I should be redirected to "/home"

	Scenario: Signed out user tries to signup again
		Given I signed up and confirmed my account
		And I am logged out
		When I go to the signup page
		And I fill in the user form with:
			| username | email            | password | password_confirmation   |
			| dave     | dave@example.com | 5eCuR3z  | 5eCuR3z                 |
		And I click the signup button
		Then I should be redirected to "/signup"
		And I should see error messages
