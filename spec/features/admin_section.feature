Feature: Admin section

  The admin section consists of two subapps. Every link in the admin menu redirects to the corresponding subapp.

  Scenario Outline: Links going to new admin
    Given there is a user
    And the user is a sysadmin
    When I log in as the user
    Then I see the admin menu
    When I click on <menu entry>
    Then I am redirected to <path>
    And I see content of the page
    When I click on "Admin"
    Then I am redirected to /admin
    And I see the admin menu
    Examples:
      | Authentication-Systems | /admin/authentication-systems |
      | Delegations            | /admin/delegations            |
      | Groups                 | /admin/groups                 |
      | System-Admins          | /admin/system-admins          |
      | Users                  | /admin/users                  |

  Scenario Outline: Links going to old admin
    Given I visit /admin
    Then I see the admin menu
    When I click on <menu entry>
    Then I am redirected to <path>
    And I see content of the page
    When I click on "Admin Top"
    Then I am redirected to /admin
    And I see the admin menu
    Examples:
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
    Given there is a user
    And the user is an admin
    When I log in as the user
    And I visit /system-admins
    Then there is an error message
