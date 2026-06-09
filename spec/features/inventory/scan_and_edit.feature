Feature: Scan and edit

  Background:
    Given there is an initial admin
    And the default locale is "en-GB"
    And there is a user
    And there is an inventory pool "Pool A"
    And the user is inventory manager of pool "Pool A"
    And there is a supplier "Test Supplier"
    And there is a model "Test Model" with 4 advanced search items in pool "Pool A"
    And I log in as the user

  Scenario: Edit by barcode
    When I go to the scan-edit page of pool "Pool A"
    And I add status note "updated via scan" on the scan-edit form
    And I scan inventory code "ADV-001"
    Then the item "ADV-001" has status note "updated via scan"

  Scenario: Edit by selection
    When I go to the scan-edit page of pool "Pool A"
    And I add status note "updated via selection" on the scan-edit form
    And I select item "ADV-002" on the scan-edit form
    And I apply the scan-edit form
    Then the item "ADV-002" has status note "updated via selection"

  Scenario: Edit all built-in fields
    When I go to the scan-edit page of pool "Pool A"
    And I set all built-in fields on the scan-edit form
    And I scan inventory code "ADV-003"
    Then the item "ADV-003" has all built-in scan-edit field values
