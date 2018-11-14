Feature: Authentication systems

  The login flow corresponds to the amount and type of authentication systems as well as to those enabled for a particular user.

  Scenario: No authentication system enabled for a user
    Given there is a user without any authentication system enabled for him/her
    When I enter the login of such a user
    And click on "Login"
    Then /sign-in page is loaded
    And there is an error message

  Scenario: User with only password authentication
    Given there is a user with password authentication
    When I enter the login of such a user
    And click on "Login"
    Then /sign-in page is loaded
    And there is a password authentication section with a password field
    When I enter the password
    And click on "Login"
    Then I am logged in successfully

  Scenario: User with only external authentication
    Given there is a user with external authentication
    When I enter the login of such a user
    And click on "Login"
    Then /sign-in page is loaded
    And there is an external authentication section with a link
    When I click on that link
    Then I am redirected to the url of that authentication system

  Scenario: User with password and external authentication
    Given there is a user with password and external authentication
    When I enter the login of such a user
    And click on "Login"
    Then /sign-in page is loaded
    And there is an external authentication section with a link
    And there is a password authentication section with a password field
