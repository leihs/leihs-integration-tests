Feature: Advanced search

  Background:
    Given there is an initial admin
    And the default locale is "en-GB"
    And there is a user
    And there is an inventory pool "Pool A"
    And the user is inventory manager of pool "Pool A"
    And there is a model "Test Model" with 4 advanced search items in pool "Pool A"
    And I log in as the user

  Scenario: Search and edit
    When I go to the search-edit page of pool "Pool A"
    And I add a search filter
    Then I see 4 search result items
    When I filter search results by inventory code "ADV-001"
    Then I see 1 search result items
    When I select the search result for inventory code "ADV-001"
    And I bulk edit status note to "updated via search"
    Then the item "ADV-001" has status note "updated via search"

  Scenario: Bulk edit search-edit fields via selection
    When I go to the search-edit page of pool "Pool A"
    And I add a search filter
    Then I see 4 search result items
    When I select all search result items
    And I open the search-edit bulk edit form
    And I set search-edit bulk field values
    And I apply the search-edit bulk edit form
    Then all advanced search items have search-edit bulk field values
