Feature: Language

  User has the possibility to switch his or her language. Switching the language in any subapp should have a global effect across all subaps.

  Scenario: Switch the language
    Given there is a user with an ultimate access
    And I log in as the user
    When I visit <subapp path>
    And I change the language
    Then the language was changed in the current <subapp path>
    And the language was changed everywhere
    When I log out
    And I log in as the user
    Then the newly changed language is the current language
    Examples:
      | subapp path       |
      | /admin            |
      | /borrow           |
      | /procure          |
      | /manage           |
      | /my               |
