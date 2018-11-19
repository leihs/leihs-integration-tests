Feature: Initial admin

  Scenario: Create initial admin
    When I go to "/"
    Then I am redirected to "/my/initial-admin"
    When I fill out the form with:
      | field                   | value                   |
      | email                   | admin@leihs.example.com |
      | password                | secret                  |
    And I click the button 'Create initial adminstrator'
    Then I am redirected to "/"
    # And I see the text:
    #   """
    #   First admin user has been created. Default database authentication system has been configured.
    #   """
    When I enter "admin@leihs.example.com" in the "user" field
    And I click on "Login"
    Then the /sign-in page is loaded
    When I enter "secret" in the "password" field
    And I click on "Weiter"
    Then I am logged in as user with email "admin@leihs.example.com"
    And I am redirected to "/admin/"
    And I see the admin interface
