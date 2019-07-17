Feature: Authentication systems

  The login flow corresponds to the amount and type of authentication systems as well as to those enabled for a particular user.

  Background:
    Given there is an initial admin

  Scenario: No authentication system enabled for a user
    Given there is a user
    And there is no authentication system enabled for the user
    And password sign in is disabled for the user
    And the user's email is "user@example.com"
    When I visit "/"
    And I enter "user@example.com" in the "user" field
    And I click on "Login"
    Then I am redirected to "/sign-in"
    And there is an error message saying that login with this account is not possible

  Scenario: User with only password authentication
    Given there is a user
    And the user is customer of some pool
    And the user has password authentication
    And the user's email is "user@example.com"
    When I visit "/"
    And I enter "user@example.com" in the "user" field
    And I click on "Login"
    Then I am redirected to "/sign-in"
    And there is a password authentication section with a password field
    When I enter "password" in the "password" field
    And I click on "Weiter"
    Then I am redirected to "/borrow"
    And I am logged in successfully

  Scenario: User with password and external authentication
    Given there is a user
    And there is an external authentication system
    And the user has external authentication
    And the user's email is "user@example.com"
    When I visit "/"
    And I enter "user@example.com" in the "user" field
    And I click on "Login"
    Then I am redirected to "/sign-in"
    And there is an external authentication section with a button
    And there is a password authentication section with a password field
    And I click on the button within the external authentication section
    Then I am redirected to the url of that authentication system

  Scenario: User with password sign in enabled (but no password) and external authentication
    Given there is a user without password
    And there is an external authentication system
    And the user has external authentication
    And the user's email is "user@example.com"
    When I visit "/"
    And I enter "user@example.com" in the "user" field
    And I click on "Login"
    Then I am redirected to "/sign-in"
    And there is an external authentication section with a button
    And there is no password authentication section with a password field
    And there is a forgot password button

  Scenario: User with only external authentication
    Given there is a user
    And there is an external authentication system
    And the user has external authentication
    And the user does not have password authentication
    And password sign in is disabled for the user
    And the user's email is "user@example.com"
    When I visit "/"
    And I enter "user@example.com" in the "user" field
    And I click on "Login" *
    Then I am redirected to the url of that authentication system
