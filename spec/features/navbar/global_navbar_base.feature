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
    And there is no section with subapps in the navbar for the "/my/user/me" subapp


