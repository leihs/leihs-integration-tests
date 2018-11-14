Feature: First Admin
  Background:
    Given there is an empty database

  Scenario: create first admin
    When I go to '/'
      Then I am redirected to '/first_admin_user'

    When I fill out the form with:
      | field                   | value                   |
      | Last name               | Admin                   |
      | First name              | Super                   |
      | E-Mail                  | admin@leihs.example.com |
      | Login                   | superadmin              |
      | Password *              | secret                  |
      | Password Confirmation * | secret                  |
      And I click the button 'Save'

    Then I am redirected to '/'
      And I see the text:
        """
        First admin user has been created. Default database authentication system has been configured.
        """

    When I enter "superadmin" in the login/email field
    And I click on "Login"
    Then the /sign-in page is loaded

    When I enter my password
    And click on "Login"
    Then I am logged in 
    And I have been redirected to /admin
