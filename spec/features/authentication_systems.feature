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

  Scenario: User account disabled
    Given there is a user
    And the user account is disabled
    And there is an external authentication system
    And the user has external authentication
    And the user has password authentication
    And the user's email is "user@example.com"
    When I visit "/"
    And I enter "user@example.com" in the "user" field
    And I click on "Login"
    Then I am redirected to "/sign-in"
    And there is an error message saying that login with this account is not possible

  Scenario: User does not exist
    Given there is an external authentication system
    When I visit "/"
    And I enter "user@example.com" in the "user" field
    And I click on "Login"
    Then I am redirected to "/sign-in"
    And there is an error message saying that login with this account is not possible

  Scenario: User without password and without email (pwd sign-in enabled)

    The user doesn't have any external authentication.
    The user can't reset his password because he has no email.
    The user can't login because he does not have password (yet).
    Although password sign-in is enabled for him, the screen would be empty,
    so we show an error screen instead.

    Given there is a user
    And the user's login is "userlogin"
    And the user does not have email
    And the user does not have password authentication
    When I visit "/"
    And I enter "userlogin" in the "user" field
    And I click on "Login" *
    Then there is an error message saying that login with this account is not possible

  Scenario: User with only 1 external authentication
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
    Then I am redirected to "/borrow/"
    And I am logged in successfully

  Scenario: User with password sign-in enabled (but no password) and 1 external authentication
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
    But there is a create password button

  Scenario: User with password and 1 external authentication
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

  Scenario: User with password and 1 external authentication but no email

    Although the user has no email, still we offer the "Password forgotten?" link.
    We show an appropriate error message on the following "/forgot-password" page.

    Given there is a user
    And there is an external authentication system
    And the user has external authentication
    And the user's login is "userlogin"
    And the user does not have email
    When I visit "/"
    And I enter "userlogin" in the "user" field
    And I click on "Login"
    Then I am redirected to "/sign-in"
    And there is an external authentication section with a button
    And there is a password authentication section with a password field
    But there is a forgot password button

  Scenario: User with 2 external authentication systems (no password authentication system exists)
    Given there is a user
    And there is an external authentication system "ext1"
    And there is an external authentication system "ext2"
    And the user has external authentication for "ext1"
    And the user has external authentication for "ext2"
    And there is no password authentication system
    And the user's email is "user@example.com"
    When I visit "/"
    And I enter "user@example.com" in the "user" field
    And I click on "Login"
    Then I am redirected to "/sign-in"
    And there is an external authentication section with a button "ext1"
    And there is an external authentication section with a button "ext2"
    And there is no password authentication section with a password field
    But there is no forgot password button

  Scenario: User with 2 external authentication systems, without email and without password (password authentication system exists)
    Given there is a user without password
    And there is an external authentication system "ext1"
    And there is an external authentication system "ext2"
    And the user has external authentication for "ext1"
    And the user has external authentication for "ext2"
    And the user's login is "userlogin"
    And the user does not have email
    When I visit "/"
    And I enter "userlogin" in the "user" field
    And I click on "Login"
    Then I am redirected to "/sign-in"
    And there is an external authentication section with a button "ext1"
    And there is an external authentication section with a button "ext2"
    And there is no password authentication section with a password field
