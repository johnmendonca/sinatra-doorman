@logout
Feature: Log out
  To protect their account from unauthorized access
  A user should be able to log out

	Scenario: User logs out
		Given I signed up and confirmed my account
		And I am logged in
		When I log out
		Then I should be redirected to "/login"
		And I should see a success notice
		And I should be logged out
