Feature: Inventory pools

  Background:
    Given there is an initial admin
    And the default locale is "en-GB"
    And there is a language "Deutsch" with locale name "de-CH"

  Scenario: Create an inventory pool and edit a mail template
    When I log in as the initial admin
    Then I am redirected to "/admin/"
    When I click on "Inventory Pools"
    Then I am redirected to "/admin/inventory-pools/"
    When I click on first "Add Inventory Pool"
    And I fill out the form with:
      | field     | value                |
      | name      | New Pool             |
      | shortname | NP                   |
      | email     | new_pool@example.com |
    And I toggle "is_active"
    And I click on "Save"
    Then I am on the show page of the pool "New Pool"
    And I click on "Users" within ".nav-tabs"
    And I select "any" from "Role"
    And I click on "Edit" within ".direct-roles"
    And I wait a little
    And I check "inventory_manager"
    And I click on "Save"
    And I wait a little
    When I go to the mail templates page of pool "New Pool"
    And I search for "approved" in "term" field
    And I select "de-CH" from "language_locale" field
    And I click on "approved"
    And I click on "Edit"
    And I fill in body with "test"
    And I click on "Save"
    And I reload the page
    And I click on "Edit"
    Then there is "test" in the body field
