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
