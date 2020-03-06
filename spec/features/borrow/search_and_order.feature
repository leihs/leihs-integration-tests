Feature: Search and order

  Background:
    Given there is an initial admin
    And there is a user
    And there is an inventory pool "Pool A"
    And the user is inventory manager of pool "Pool A"

  Scenario: Search and order
    Given there is a model "Kamera"
    And there are 4 borrowable items for model "Kamera" in pool "Pool A"
    And there is a model "Beamer"
    And there is 1 borrowable item for model "Beamer" in pool "Pool A"

    When I log in as the user

    # search for a model
    And I visit "/app/borrow/"
    And I enter "Kamera" in the search field
    And I choose next working day as start date
    And I choose next next working day as end date
    And I click on "Get Results"
    Then I see one model with the title "Kamera"

    # make a reservation
    When I click on the model with the title "Kamera"
    Then the show page of the model "Kamera" was loaded
    And the start date chosen on the previous screen is pre-filled
    And the end date chosen on the previous screen is pre-filled
    And the maximum quantity shows 4
    When I set the quantity to 3
    And I click on "Order" and accept the alert
    Then the maximum quantity shows 1

    # check the cart
    When I click on the menu
    And I click on "Cart"
    Then the cart page is loaded
    And I see one reservation for model "Kamera"
    And the reservation has quantity 3
    # And the start date is the one chosen before
    # And the end date is the one chosen before

    # change the quantity and the dates of a reservation in the cart
    # ...
    
    # make a reservation for another model
    When I click on "LEIHS"
    Then "Kamera" is pre-filled as the search term
    And the start date chosen on the previous screen is pre-filled
    And the end date chosen on the previous screen is pre-filled
    When I enter "Beamer" in the search field
    And I click on "Get Results"
    Then I see one model with the title "Beamer"
    When I click on the model with the title "Beamer"
    And I set the quantity to 1
    And I click on "Order" and accept the alert

    # check the cart
    When I click on the menu
    And I click on "Cart"
    Then the cart page is loaded
    And I see one reservation for model "Beamer"

    # delete a reservation
    And I delete the reservation for model "Kamera"
    Then the reservation for model "Kamera" was deleted from the cart

    # submit the order
    When I name the order as "My order"
    And I click on "Confirm order" and accept the alert
    Then the cart is empty

    # approve the order in legacy
    When I visit the orders page of the pool "Pool A"
    Then I approve the order of the user

    # check the new status of the order
    When I visit "/app/borrow/"
    And I click on the menu
    And I click on "Orders"
    Then I see the order "My order" under approved orders