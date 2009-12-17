Feature: Sign up
  In order to use most of the features of the site
  A user should be able to sign up

	Scenario Outline: User inputs invalid signup information
		Given that the following users exist
			| username | email            |
			| john     | john@example.com |
		When I go to the signup page
		And I fill the user form with:
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
			| contact  | guy@example.com  | aWeSoMeG | aWeSoMeG              |
			| guy      | guy@example.com  | aWeSoMeG | radicall              |

	Scenario: User supplies valid, untaken information
		Given that the following users exist
			| username | email            |
			| john     | john@example.com |
		When I go to the signup page
		And I fill the user form with:
			| username | email            | password | password_confirmation   |
			| dave     | dave@example.com | 5eCuR3z  | 5eCuR3z                 |
		And I click the signup button
		Then I should be redirected to root
		And I should see a success notice
		And I should receive an email
		And I should see "/confirm" in the email body

	@wip
    Scenario: User confirms his account
      Given I signed up with "email@person.com/password"
      When I follow the confirmation link sent to "email@person.com"
      Then I should see "Confirmed email and signed in"
      And I should be signed in

	@wip
    Scenario: Signed in user clicks confirmation link again
      Given I signed up with "email@person.com/password"
      When I follow the confirmation link sent to "email@person.com"
      Then I should be signed in
      When I follow the confirmation link sent to "email@person.com"
      Then I should see "Confirmed email and signed in"
      And I should be signed in

	@wip
    Scenario: Signed out user clicks confirmation link again
      Given I signed up with "email@person.com/password"
      When I follow the confirmation link sent to "email@person.com"
      Then I should be signed in
      When I sign out
      And I follow the confirmation link sent to "email@person.com"
      Then I should see "Already confirmed email. Please sign in."
      And I should be signed out

	@wip
	Scenario: Signed in user tries to signup
