Feature: Redirects after login

  Background:
    Given there is an initial admin

  Scenario: Leihs admin only
    Given there is a user
    And the user is leihs admin
    When I log in as the user
    Then I am redirected to "/admin/"

  Scenario: Leihs admin and manager
    Given there is a user
    And the user is leihs admin
    And the user is inventory manager of some pool
    When I log in as the user
    Then I am redirected to "/admin/"

  Scenario: Leihs admin and procurer
    Given there is a user
    And the user is leihs admin
    And the user is procurement admin
    When I log in as the user
    Then I am redirected to "/admin/"

  Scenario: Leihs admin and customer
    Given there is a user
    And the user is leihs admin
    And the user is customer of some pool
    When I log in as the user
    Then I am redirected to "/admin/"

  Scenario: Manager of different pools
    Given there is a user
    And the user is group manager of pool A
    And the user is inventory manager of pool B
    When I log in as the user
    Then I am redirected to the inventory path of pool B

  Scenario: Customer only
    Given there is a user
    And the user is customer of some pool
    When I log in as the user
    Then I am redirected to "/borrow"

  Scenario: Procurer only
    Given there is a user
    And the user does not have any pool access rights
    And the user is procurement requester
    When I log in as the user
    Then I am redirected to "/procure/requests"

  Scenario: Customer and procurer
    Given there is a user
    And the user is procurement requester
    And the user is customer of some pool
    When I log in as the user
    Then I am redirected to "/borrow"

  Scenario: Procurer and manager
    Given there is a user
    And the user is procurement requester
    And the user is inventory manager of some pool
    When I log in as the user
    Then I am redirected to the inventory path of the pool

  Scenario: User with no access whatsoever
    Given there is a user
    And the user has no access whatsoever
    When I log in as the user
    Then I am redirected to "/my/user/me"
