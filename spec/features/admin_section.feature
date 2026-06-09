Feature: Admin section

  The admin section consists of two subapps. Every link in the admin menu redirects to the corresponding subapp.

  Background:
    Given there is an initial admin

  Scenario Outline: Links going to new admin
    When I log in as the initial admin
    Then I am redirected to "/admin/"
    And I see the admin menu
    When I click on <menu entry> within the admin menu
    Then I am redirected to "<path>"
    And I see the content of the <menu entry> page
    # When I click on "Admin"
    # Then I am redirected to "/admin/"
    # And I see the admin menu
    Examples:
      | menu entry             | path                           |
      | 'Inventory Pools'      | /admin/inventory-pools/        |
      | Users                  | /admin/users/                  |
      | Groups                 | /admin/groups/                 |
      | Statistics             | /admin/statistics/             |
      | Fields                 | /admin/inventory-fields/       |
      | Buildings              | /admin/buildings/              |
      | Rooms                  | /admin/rooms/                  |
      | Suppliers              | /admin/suppliers/              |
      | 'Mail Templates'       | /admin/mail-templates/         |

  Scenario: No access to system-admins for a leihs admin
    Given there is a leihs admin
    When I log in as the leihs admin
    And I visit "/admin/system-admins"
    Then there is an error message

  Scenario Outline: Create dynamic fields for inventory pool and test appearance in /inventory
    And the default locale is "en-GB"
    When I log in as the initial admin
    Then I am redirected to "/admin/"

    When I click on "Inventory Pools"

    # Create inventory pool
    Then I am redirected to "/admin/inventory-pools/"
    When I click on first "Add Inventory Pool"
    And I fill out the form with:
    | field     | value                |
    | name      | New Pool             |
    | shortname | NP                   |
    | email     | new_pool@example.com |
    And I click on "Save"

    Then I am on the show page of the pool "New Pool"
    And I click on "Users" within ".nav-tabs"
    And I select "any" from "Role"
    And I click on "Edit" within ".direct-roles"
    And I wait a little
    And I check "inventory_manager"
    And I click on "Save"
    And I wait a little


    # Create dynamic fields
    And I see the admin menu
    When I click on <menu entry> within the admin menu
    Then I am redirected to "<path>"
    And I see the content of the <menu entry> page
    And I create field: "test_select" "Select"
    And I activate field

    And I see the admin menu
    When I click on <menu entry> within the admin menu
    Then I am redirected to "<path>"
    And I see the content of the <menu entry> page
    And I create field: "test_text" "Text"
    And I activate field

    And I see the admin menu
    When I click on <menu entry> within the admin menu
    Then I am redirected to "<path>"
    And I see the content of the <menu entry> page
    And I create field: "test_textarea" "Textarea"
    And I activate field

    And I see the admin menu
    When I click on <menu entry> within the admin menu
    Then I am redirected to "<path>"
    And I see the content of the <menu entry> page
    And I create field: "test_radio" "Radio"
    And I activate field

    And I see the admin menu
    When I click on <menu entry> within the admin menu
    Then I am redirected to "<path>"
    And I see the content of the <menu entry> page
    And I create field: "test_date" "Date"
    And I activate field

    And I see the admin menu
    When I click on <menu entry> within the admin menu
    Then I am redirected to "<path>"
    And I see the content of the <menu entry> page
    And I create field: "test_checkbox" "Checkbox"
    And I activate field

    When I click on "Fields"
    And I fill out the form with:
    | field     | value            |
    | term      | test             |
    And I wait a little
    Then I see 6 inventory field rows


    When I redirect to "/inventory/"
    Then I am redirected to "/inventory/"

    And there is a model "Test Model" with 2 matching and 2 non-matching test items in pool "New Pool"

    When I go to the search-edit page of pool "New Pool"
    And I add a search filter
    Then I see 4 search result items

    When I select each test filter field
    Then I see 2 search result items

    When I go to the scan-edit page of pool "New Pool"
    And I set all test dynamic fields on the scan-edit form
    And I scan inventory code "TEST-SCAN-001"
    Then the item "TEST-SCAN-001" has test dynamic field values

    Examples:
      | menu entry | path                     |
      | Fields     | /admin/inventory-fields/ |
