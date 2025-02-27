Feature: Search and order

  Background:
    Given there is an initial admin
    And there is a user
    And there is an inventory pool "Pool A"
    And the user is inventory manager of pool "Pool A"
    And the default locale is "en-GB"

  Scenario: Search and order
    Given there is a model "Kamera"
    And there are 4 borrowable items for model "Kamera" in pool "Pool A"
    And there is a model "Beamer"
    And there is 1 borrowable item for model "Beamer" in pool "Pool A"
    When I log in as the user

    # search for a model
    And I visit "/borrow/"
    And I enter "Kamera" in the "Search term" field
    And I click on "Search"
    Then the search field contains "Kamera"

    When I click on "availability"
    And I choose next working day as start date
    And I choose next next working day as end date
    And I click button "Apply"
    Then I see one model with the title "Kamera"
    And the search filters are persisted in the url

    # make a reservation
    When I click on the model with the title "Kamera"
    Then the show page of the model "Kamera" was loaded
    When I click on "Add item"
    Then the order panel is shown
    And the start date chosen previously is pre-filled in the calendar
    And the end date chosen previously is pre-filled in the calendar
    When I set the quantity to 3
    And I click on "Add"
    And I accept the "Item added" dialog

    # check the cart
    When I click on the cart icon
    And the cart page is loaded
    Then I see the following lines in the "Items" section:
      | title     |
      | 3× Kamera |

    # make a reservation for another model
    When I click on "Leihs"
    And I enter "Kamera" in the "Search term" field
    And I click on "Search"

    # test query params and filters
    When I clear ls from the borrow app-db
    And I visit "/borrow/models" with query params for dates as before but "Beamer" as term
    And I click on "availability"
    Then the start date chosen previously is pre-filled in the search panel
    And the end date chosen previously is pre-filled in the search panel
    And I click button "Apply"
    Then I see one model with the title "Beamer"
    When I click on the model with the title "Beamer"
    And I click on "Add item"
    Then the order panel is shown
    And I set the quantity to 1
    And I click on "Add"
    And I accept the "Item added" dialog

    # check the cart
    When I click on the cart icon
    Then the cart page is loaded
    And I wait for 1 second
    Then I see the following lines in the "Items" section:
      | title     |
      | 1× Beamer |
      | 3× Kamera |

    # change the quantity and the dates of a reservation in the cart
    When I click on the line of the model "Kamera"
    When I increase the start date by 1 day for the model "Kamera"
    And I increase the end date by 1 day for the model "Kamera"
    And I set the quantity in the cart line to 4
    And I click on "Confirm"
    And I wait for 1 second
    Then I see the following lines in the "Items" section:
      | title     |
      | 1× Beamer |
      | 4× Kamera |

    # delete a reservation
    When I wait for 1 second
    And I click on the line of the model "Beamer"
    And I see the "Edit reservation" dialog
    And I click on "Remove reservation"
    And the "Edit reservation" dialog has closed
    Then I see the following lines in the "Items" section:
      | title     |
      | 4× Kamera |

    # submit the order
    When I wait for 1 second
    When I click on "Send order"
    And I see the "Send order" dialog
    And I enter "Order 1" in the "Title" field
    And I click on "Send"
    And the "Send order" dialog has closed
    And I accept the "Order submitted" dialog
    And the "Order submitted" dialog has closed
    Then I have been redirected to the orders list
    And there is an email for the user with the title "[leihs] Reservation Submitted"

    # approve the order in legacy
    When I visit the orders page of the pool "Pool A"
    Then I approve the order of the user

    # check the new status of the order
    When I visit "/borrow/"
    And I click on "Orders"
    And I click on "Active orders"
    And I click on the order "Order 1"
    Then I see "0 of 4 items picked up" in the "State" section
    And I see the following lines in the "Items" section:
      | title                       |
      | 1× Kamera\nPick up tomorrow |
      | 1× Kamera\nPick up tomorrow |
      | 1× Kamera\nPick up tomorrow |
      | 1× Kamera\nPick up tomorrow |
