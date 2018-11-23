Feature: Global session

  If one logs in as a user who has access to all subapps, then should be logged in for every subapp. Also, if one logs out from any subapp, then one should be logged out for every subapp.

  Scenario Outline: Logged in everywhere
    Given there is a user with an ultimate access
    When I log in as the user
    And I visit "<subapp path>"
    Then I am logged in "<subapp path>"
    Examples:
      | subapp path       |
      | /admin/           |
      | /borrow           |
      | /procure          |
      | /manage           |
      | /my               |

  Scenario Outline: Log out from a particular subapp and thus everywhere
    Given there is a user with an ultimate access
    When I log in as the user
    And I visit "<subapp path>"
    And I log out from "<subapp path>"
    Then I am redirected to "/"
    And I am logged out from "/admin/"
    And I am logged out from "/borrow"
    And I am logged out from "/procure"
    And I am logged out from "/manage"
    And I am logged out from "/my"
    Examples:
      | subapp path       |
      | /admin            |
      | /borrow           |
      | /procure          |
      | /manage           |
      | /my               |
