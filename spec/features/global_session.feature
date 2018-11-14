Feature: Global session

  If one logs in as a user who has access to all subapps, then should be logged in for every subapp. Also, if one logs out from any subapp, then one should be logged out for every subapp.

  Scenario: Logged in everywhere
    Given there is a user with ultimate access
    When I log in as the user
    And I visit <subapp path>
    Then I am logged in there
    Examples:
      | subapp path       |
      | /admin            |
      | /borrow           |
      | /procure          |
      | /manage           |
      | /my               |

  Scenario: Log out from a particular subapp and thus everywhere
    Given there is a user with ultimate access
    When I log in as the user
    And I visit <subapp path>
    And I click on "Log out" in the navbar
    Then I am redirected to "/"
    And I am logged out everywhere
    Examples:
      | subapp path       |
      | /admin            |
      | /borrow           |
      | /procure          |
      | /manage           |
      | /my               |
