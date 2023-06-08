Feature: Redirects after login

  Background:
    Given there is an initial admin
    And there is a user

  Scenario: Leihs admin only
    Given the user is leihs admin
    When I log in as the user
    Then I am redirected to "/admin/"

  Scenario: Leihs admin and manager
    Given the user is leihs admin
    And the user is inventory manager of some pool
    When I log in as the user
    Then I am redirected to "/admin/"

  Scenario: Leihs admin and procurer
    Given the user is leihs admin
    And the user is procurement admin
    When I log in as the user
    Then I am redirected to "/admin/"

  Scenario: Leihs admin and customer
    Given the user is leihs admin
    And the user is customer of some pool
    When I log in as the user
    Then I am redirected to "/admin/"

  Scenario: Manager of different pools
    Given the user is group manager of pool A
    And the user is inventory manager of pool B
    When I log in as the user
    Then I am redirected to the inventory path of pool B

  Scenario: Customer only
    Given the user is customer of some pool
    When I log in as the user
    Then I am redirected to "/borrow/"

  Scenario: Procurer only
    Given the user does not have any pool access rights
    And the user is procurement requester
    When I log in as the user
    Then I am redirected to "/procure/requests"

  Scenario: Customer and procurer
    Given the user is procurement requester
    And the user is customer of some pool
    When I log in as the user
    Then I am redirected to "/borrow/"

  Scenario: Procurer and manager
    Given the user is procurement requester
    And the user is inventory manager of some pool
    When I log in as the user
    Then I am redirected to the inventory path of the pool

  Scenario: User with no access whatsoever
    Given the user has no access whatsoever
    When I log in as the user
    Then I am redirected to "/my/user/me"

  Scenario Outline: Redirect with return-to param
    Given there is an external authentication system "test ext auth"
    And there is a user with an ultimate access
    And the external authentication system is configured for the user
    When I visit "<path>"
    Then I am redirected to sign in page
    When I enter my email address
    And I click on "Weiter"
    And I click on "test ext auth"
    And I confirm my identity
    Then I am redirected to "<path>"
    Examples:
      | path                               |
      | /borrow/debug?foo=bar&baz=quux |
      | /procure/requests                  |
