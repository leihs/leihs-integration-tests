Feature: Global navbar

  The global navbar looks different for each subapp but should contain common entries. The specific subapp links should correspond to the roles of the logged in user and should redirect to the appropriate place.

  Background:
    Given there is an initial admin

  Scenario: Navbar for a manager of different pools, an admin and procurer
    Given there is a user
    And the user is inventory manager of pool "Pool A"
    And the user is group manager of pool "Pool B"
    And the user is leihs admin
    And the user is procurement requester
    When I log in as the user
    Then I am redirected to "/admin/"
    And there is a section in the navbar for "/admin" with following subapps:
      | Ausleihen         |
      | Bedarfsermittlung |
      | Pool A            |
      | Pool B            |
    When I click on "Ausleihen"
    Then I am redirected to "/borrow/"
    And there is a section in the navbar for "/borrow" with following subapps:
      | Ausleihen         |
      | Admin             |
      | Bedarfsermittlung |
      | Pool A            |
      | Pool B            |
    When I click on "Admin"
    Then I am redirected to "/admin/"
    And I open the subapps dropdown
    And I click on "Bedarfsermittlung"
    Then there is a section in the navbar for "/procure" with following subapps:
      | Ausleihen         |
      | Admin             |
      | Pool A            |
      | Pool B            |
    When I click on "Admin"
    Then I am redirected to "/admin/"
    And I open the subapps dropdown
    And I click on "Pool A"
    Then I am redirected to the daily path of pool "Pool A"
    Then there is a section in the navbar for "/manage" with following subapps:
      | Ausleihen         |
      | Admin             |
      | Bedarfsermittlung |
      | Pool A            |
      | Pool B            |
