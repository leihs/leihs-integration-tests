Feature: New Inventory

  Background:
    Given there is an initial admin

  Scenario: Not logged in
    When I visit "/inventory"
    Then I see the /inventory main page
    When I click on "Inventory List"
    Then I see the inventory list page
    Then I am redirected to "/inventory/models/inventory-list"

