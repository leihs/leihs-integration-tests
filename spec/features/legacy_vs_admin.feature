Feature: Legacy vs Admin

  Background:
    Given there is a user with an ultimate access
    And the default locale is "en-GB"
    And there is an inventory pool "Pool A"
    And the user is inventory manager of pool "Pool A"

  Scenario: There is a notice with a link to admin in old legacy manage pool section
    When I log in as the user
    And I visit the daily section of pool "Pool A" in legacy
    And I click on "Manage"
    Then the current path are the entitlement groups of pool "Pool A"
    Then I should see a notice with a link to the admin
    When I click on the link in the notice
    Then I am redirected to the manage section of the pool "Pool A" in admin
