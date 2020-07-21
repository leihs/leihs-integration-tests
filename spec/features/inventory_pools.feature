Feature: Inventory pools

  Background:
    Given there is an initial admin
    And there is a default language "English" with locale name "en-GB"
    And there is a language "Deutsch" with locale name "de-CH"
    And there are meta mail templates

  Scenario: Create an inventory pool and edit a mail template
    When I log in as the initial admin
    Then I am redirected to "/admin/"
    When I click on "Inventory-Pools"
    Then I am redirected to "/admin/inventory-pools/"
    When I click on "Add Inventory-Pool"
    And I fill out the form with:
      | field     | value                |
      | name      | New Pool             |
      | shortname | NP                   |
      | email     | new_pool@example.com |
    And I check "is_active"
    And I click on "Add"
    Then I am on the show page of the pool "New Pool"
    And I click on "Users"
    And I click on "none"
    And I click on "Direct Roles" within the navigation
    And I check "inventory_manager"
    And I click on "Save"
    When I go to the mail templates page of pool "New Pool"
    And I click on "Edit" for template "approved"
    And I enter "test" for all languages
    And I click on "Save Mail Templates"
    And I click on "Edit" for template "approved"
    Then all languages contain "test"
