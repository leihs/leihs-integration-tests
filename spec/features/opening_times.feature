Feature: Opening times of a pool

  Background:
    Given there is a user with an ultimate access
    And the default locale is "en-GB"
    And there is an inventory pool "Pool X"
    And the user is inventory manager of pool "Pool X"

  Scenario: Adjust the opening times in admin and check their display in borrow
    When I log in as the user
    And I am redirected to "/admin/"
    And I click on "Inventory Pools"
    Then I am redirected to "/admin/inventory-pools/"
    When I click on "Pool X"
    And I click on "Opening Times"
    And I click on "Edit" within "Workdays"
    And I mark "Monday" as closed
    And I set Hours Info for "Monday" to "8:00 - 10:00"
    And I set Hours Info for "Tuesday" to "come anytime"
    And I mark "Sunday" as closed
    And I click on "Save"
    Then "Monday" is closed and has "8:00 - 10:00" as hours info
    And "Tuesday" is open and has "come anytime" as hours info
    And "Wednesday" is open and has no hours info
    And "Thursday" is open and has no hours info
    And "Friday" is open and has no hours info
    And "Saturday" is open and has no hours info
    And "Sunday" is closed and has no hours info
    And I click on "Edit" within "Holidays"
    And I add a current holiday "Holiday Current"
    And I add a future holiday "Holiday Future"
    And I click on "Save"
    Then I see a holiday "Holiday Current"
    And I see a holiday "Holiday Future"
    When I visit "/borrow/"
    And I click on "Inventory Pools"
    And I click on inventory pool "Pool X"
    Then for "Monday" there is a message "Closed"
    And for "Tuesday" there is a message "come anytime"
    And for "Wednesday" there is no message
    And for "Thursday" there is no message
    And for "Friday" there is no message
    And for "Saturday" there is no message
    And for "Sunday" there is a message "Closed"
    And there is holiday "Holiday Current"
    And there is holiday "Holiday Future"
