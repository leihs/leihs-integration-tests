Feature: Redirects after login

  Scenario: Admin only
    Given there is a user
    And the user is admin
    When I log in as the user
    Then I am redirected to /admin

  Scenario: Admin and manager
    Given there is a user
    And the user is admin
    And the user is an inventory manager of some pool
    When I log in as the user
    Then I am redirected to /admin

  Scenario: Admin and procurer
    Given there is a user
    And the user is admin
    And the user is a procurement admin
    When I log in as the user
    Then I am redirected to /admin

  Scenario: Admin and customer
    Given there is a user
    And the user is admin
    And the user is a customer of some pool
    When I log in as the user
    Then I am redirected to /admin

  Scenario: Manager of different pools
    Given there is a user
    And the user is group manager of pool A
    And the user is inventory manager of pool B
    When I log in as the user
    Then I am redirected to ?

  Scenario: Customer only
    Given there is a user
    And the user is customer of some pool
    When I log in as the user
    Then I am redirected to /borrow

  Scenario: Procurer only
    Given there is a user
    And the user is procurement requester
    When I log in as the user
    Then I am redirected to /procure

  Scenario: Customer and procurer
    Given there is a user
    And the user is procurement requester
    And the user is customer of some pool
    When I log in as the user
    Then I am redirected to /procure

  Scenario: Procurer and manager
    Given there is a user
    And the user is procurement requester
    And the user is inventory manager of some pool
    When I log in as the user
    Then I am redirected to ?
