Feature: Initial Setup
  Background:
    Given there is an empty database

  Scenario: create first admin
    When I go to '/'
      Then I am redirected to '/first_admin_user'

    When I fill out the form 'form[action="/first_admin_user"]' with:
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
