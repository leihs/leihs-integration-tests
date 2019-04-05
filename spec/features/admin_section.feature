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
    When I click on "Admin"
    Then I am redirected to "/admin/"
    And I see the admin menu
    Examples:
      | menu entry             | path                           |
      | Delegations            | /admin/delegations/            |
      | Groups                 | /admin/groups/                 |
      | System                 | /admin/system/                 |
      | Users                  | /admin/users/                  |

  Scenario Outline: Links going to old admin
    When I log in as the initial admin
    Then I am redirected to "/admin/"
    Then I see the admin menu
    When I click on "<menu entry>" within the admin menu
    Then I am redirected to "<path>"
    And I see the content of the "<menu entry>" page in the old admin
    When I click on "Admin Top"
    Then I am redirected to "/admin/"
    And I see the admin menu
    Examples:
      | menu entry             | path                          |
      | Audits                 | /admin/audits                 |
      | Buildings              | /admin/buildings              |
      | Fields                 | /admin/fields_editor          |
      | Inventory Pools        | /admin/inventory_pools        |
      | Languages              | /admin/languages              |
      | Mail Templates         | /admin/mail_templates         |
      | Rooms                  | /admin/rooms                  |
      | Settings               | /admin/settings               |
      | Statistics             | /admin/statistics             |
      | Suppliers              | /admin/suppliers              |

  Scenario: No access to system-admins for a leihs admin
    Given there is a leihs admin
    When I log in as the leihs admin
    And I visit "/admin/system-admins"
    Then there is an error message
