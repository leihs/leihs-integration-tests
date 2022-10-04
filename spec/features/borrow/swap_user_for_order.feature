Feature: Swap order's user

  Background:
    Given there is an initial admin
    And there is a user "Lending Manager"
    And there is an inventory pool "Pool A"
    And there is an inventory pool "Pool B"
    And the user "Lending Manager" is lending manager of pool "Pool A"
    And the user "Lending Manager" is lending manager of pool "Pool B"
    And there is a user "Normal Customer"
    And the user "Normal Customer" is customer of pool "Pool A"
    And the user "Normal Customer" is customer of pool "Pool B"
    And there is a model "Kamera"
    And there is 1 borrowable item for model "Kamera" in pool "Pool A"
    And there is a model "Beamer"
    And there is 1 borrowable item for model "Beamer" in pool "Pool B"
    And the default locale is "en-GB"

  Scenario: Customer order with a single pool order
    Given I log in as the user "Lending Manager"

    # Add model to cart
    And I visit the model show page of model "Kamera"
    When I click on "Add item"
    And I click on "Add"
    And I click on "OK"

    # Submit order
    When I click on "Cart"
    When I click on "Send order"
    And I see the "Send order" dialog
    And I enter "Test Swap" in the "Title" field
    And I click on "Send"
    And the "Send order" dialog has closed
    And I accept the "Order submitted" dialog

    # Swap user in legacy
    When I visit the page of order "Test Swap" in pool "Pool A" in legacy
    And I change the orderer to "Normal Customer"

    # Check the order lists of the old borrower
    When I visit "/app/borrow/"
    And I click on "My Orders"
    Then I see "Nothing found"

    # Check the order lists of the new borrower
    When I open the user menu
    And I click on "Logout"
    And I log in as the user "Normal Customer"
    When I visit "/app/borrow/"
    And I click on "My Orders"
    Then I see the order "Test Swap" under open orders

  Scenario: Customer order with multiple pool orders
    Given I log in as the user "Lending Manager"

    # Add model from pool 1 to cart
    And I visit the model show page of model "Kamera"
    When I click on "Add item"
    And I click on "Add"
    And I click on "OK"

    # Add model from pool 2 to cart
    And I visit the model show page of model "Beamer"
    When I click on "Add item"
    And I click on "Add"
    And I click on "OK"

    # Submit order
    When I click on "Cart"
    And I click on "Send order"
    And I see the "Send order" dialog
    And I enter "Test Swap" in the "Title" field
    And I click on "Send"
    And the "Send order" dialog has closed
    And I accept the "Order submitted" dialog

    # Swap user in legacy
    When I visit the page of order "Test Swap" in pool "Pool A" in legacy
    And I change the orderer to "Normal Customer"

    # Check the order lists of the old borrower
    When I visit "/app/borrow/"
    And I click on "My Orders"
    Then I see the order "Test Swap" under open orders
    When I click on the order "Test Swap"
    Then I see "Beamer"
    And I see "Pool B"
    But I don't see "Kamera"
    And I don't see "Pool A"

    # Check the order lists of the new borrower
    When I open the user menu
    And I click on "Logout"
    And I log in as the user "Normal Customer"
    When I visit "/app/borrow/"
    And I click on "My Orders"
    Then I see the order "Test Swap" under open orders
    When I click on the order "Test Swap"
    Then I see "Kamera"
    And I see "Pool A"
    But I don't see "Beamer"
    And I don't see "Pool B"
