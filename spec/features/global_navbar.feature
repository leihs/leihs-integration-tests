Feature: Global navbar

  The global navbar looks different for each subapp but should contain common entries. The specific subapp links should correspond to the roles of the logged in user and should redirect to the appropriate place.

  Background:
    Given there is an initial admin

  Scenario: Navbar for customer only
    Given there is a user
    And the user is customer of some pool
    When I log in as the user
    Then I am redirected to "/borrow"
    And there is no section with subapps in the navbar for the "/borrow" subapp

  Scenario: Navbar for a procurer only
    Given there is a user
    And the user does not have any pool access rights
    And the user is procurement requester
    When I log in as the user
    Then I am redirected to "/procure/requests"
    And there is no section with subapps in the navbar for the "/procure" subapp

  Scenario: Navbar for an leihs admin only
    Given there is a user
    And the user does not have any pool access rights
    And the user is leihs admin
    When I log in as the user
    Then I am redirected to "/admin/"
    And there is no section with subapps in the navbar for the "/admin" subapp

  Scenario: Navbar for a sysadmin
    Given there is a user
    And the user does not have any pool access rights
    And the user is sysadmin
    When I log in as the user
    Then I am redirected to "/admin/"
    Then there is no section with subapps in the navbar for the "/admin" subapp

  Scenario: Navbar for user with no access whatsoever
    Given there is a user
    And the user has no access whatsoever
    When I log in as the user
    Then I am redirected to "/my/user/me"
    And there is no section with subapps in the navbar for the "/my" subapp

  Scenario: Navbar for a sysadmin and manager
    Given there is a user
    And the user is sysadmin
    And the user is inventory manager of pool "Pool A"
    When I log in as the user
    Then I am redirected to "/admin/"
    And there is a section in the navbar for "/admin" with following subapps:
      | Ausleihen |
      | Pool A    |
    When I click on "Ausleihen"
    Then I am redirected to "/borrow"
    And there is a section in the navbar for "/borrow" with following subapps:
      | Admin     |
      | Pool A    |
    When I click on "Admin"
    Then I am redirected to "/admin"
    When I open the subapps dropdown
    And I click on "Pool A"
    Then I am redirected to the inventory path of pool "Pool A"
    And there is a section in the navbar for "/admin" with following subapps:
      | Ausleihen |
      | Admin     |
    When I click on "Admin"
    Then I am redirected to "/admin"

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
    Then I am redirected to "/borrow"
    And there is a section in the navbar for "/borrow" with following subapps:
      | Admin             |
      | Bedarfsermittlung |
      | Pool A            |
      | Pool B            |
    When I click on "Admin"
    Then I am redirected to "/admin"
    And I open the subapps dropdown
    And I click on "Bedarfsermittlung"
    Then there is a section in the navbar for "/procure" with following subapps:
      | Ausleihen         |
      | Admin             |
      | Pool A            |
      | Pool B            |
    When I click on "Admin"
    Then I am redirected to "/admin"
    And I open the subapps dropdown
    And I click on "Pool A"
    Then I am redirected to the inventory path of pool "Pool A"
    Then there is a section in the navbar for "/manage" with following subapps:
      | Ausleihen         |
      | Admin             |
      | Bedarfsermittlung |
      | Pool A            |

  Scenario Outline: Links in the user section
    Given there is a user with an ultimate access
    And firstname of the user is "Foo"
    And lastname of the user is "Bar"
    And there is a language "Deutsch" with locale name "de-CH"
    And user's preferred language is "Deutsch"
    And I log in as the user
    When I visit "<subapp path>"
    And I open the user dropdown for the "<subapp path>"
    Then I see following entries in the user section for the "<subapp path>" :
      | F. Bar          |
      | Benutzerdaten   |
      | Meine Dokumente |
      | Logout          |
    When I click on "Benutzerdaten"
    Then I am redirected to "/borrow/user"
    When I visit "<subapp path>"
    And I open the user dropdown for the "<subapp path>"
    And I click on "Meine Dokumente"
    Then I am redirected to "/borrow/user/documents"
    Examples:
      | subapp path                                            |
      | /admin/                                                |
      | /borrow                                                |
      | /procure                                               |
      | /manage/6bf7dc96-2b11-43c1-9f49-c58a5b332517/inventory |
      | /my/user/me                                            |

  # Scenario Outline: Languages
  #   Given there is a user with an ultimate access
  #   And there is language "Foo"
  #   And there is language "Bar"
  #   When I visit <subapp path>
  #   Then I see language entries as follows:
  #     | Foo |
  #     | Bar |
  #   Examples:
  #     | subapp path       |
  #     | /admin            |
  #     | /borrow           |
  #     | /procure          |
  #     | /manage           |
  #     | /my               |
