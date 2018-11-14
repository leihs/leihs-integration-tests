Feature: Global navbar

  The global navbar looks different for each subapp but should contain common entries. The specific subapp links should correspond to the roles of the logged in user and should redirect to the appropriate place.

  Scenario: Navbar for customer only
    When I log in as a customer
    Then there is no section with subapps in the navbar

  Scenario: Navbar for a procurer only
    When I log in as a procurer
    Then there is no section with subapps in the navbar

  Scenario: Navbar for an admin only
    When I log in as an admin
    Then there is no section with subapps in the navbar

  Scenario: Navbar for a sysadmin
    When I log in as an admin
    Then there is no section with subapps in the navbar

  Scenario: Navbar for a sysadmin and manager
    Given there is a user
    And the user is sysadmin
    And the user is inventory manager for a pool A
    When I log in as the user
    Then there is a section in the navbar with following subapps:
      | Admin  |
      | Pool A |

  Scenario: Navbar for a manager of different pools, an admin and procurer
    Given there is a user
    And the user is "inventory_manager" for "Pool A"
    And the user is "group_manager" for "Pool B"
    And the user is an admin
    And the user is a procurer
    When I log in as the user
    Then there is a section for the subapps in the navbar
    And it contains <subapp name>
    When I click on <subapp name>
    Then I am redirected to <subapp path>
    Examples:
      | subapp name | subapp path       |
      | Admin       | /admin            |
      | Borrow      | /borrow           |
      | Procurement | /procure          |
      | Pool A      | /manage/.*/daily  |
      | Pool B      | /manage/.*/orders |

  Scenario: Links in the user section
