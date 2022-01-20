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
    And I visit "/app/borrow/"
    And I click on "Show search/filter"
    And I enter "Kamera" in the search field
    Then the search field contains "Kamera"

    When I choose to filter by availabilty
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
    # PENDING: And the maximum quantity shows 4
    When I set the quantity to 3
    And I click on "Add"
    And I accept the "Item added" dialog

    # PENDING: Then the maximum quantity shows 1

    # check the cart
    When I open the main menu
    And I click on "New Rental"
    And the cart page is loaded
    Then I see the following lines in the "Items" section:
      | title     | body   |
      | 3× Kamera | Pool A |
    # And the start date is the one chosen before
    # And the end date is the one chosen before

    # make a reservation for another model
    When I click on "Leihs"
    And I click on "Show search/filter"
    Then "Kamera" is pre-filled as the search term
    And the start date chosen previously is pre-filled in the search panel
    And the end date chosen previously is pre-filled in the search panel

    # test query params and filters
    When I clear ls from the borrow app-db
    And I visit "/app/borrow/models" with query params for dates as before but "Beamer" as term
    And I click on "Show search/filter"
    Then "Beamer" is pre-filled as the search term
    And the start date chosen previously is pre-filled in the search panel
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
    When I open the main menu
    And I click on "New Rental"
    Then the cart page is loaded
    And I wait for 1 second
    Then I see the following lines in the "Items" section:
      | title     | body   |
      | 1× Beamer | Pool A |
      | 3× Kamera | Pool A |

    # change the quantity and the dates of a reservation in the cart
    When I click on the line of the model "Kamera"
    When I increase the start date by 1 day for the model "Kamera"
    And I increase the end date by 1 day for the model "Kamera"
    And I set the quantity in the cart line to 4
    And I click on "Confirm"
    And I wait for 1 second
    Then I see the following lines in the "Items" section:
      | title     | body   |
      | 1× Beamer | Pool A |
      | 4× Kamera | Pool A |

    # delete a reservation
    When I wait for 1 second
    And I click on the line of the model "Beamer"
    And I see the "Edit reservation" dialog
    And I click on "Remove reservation"
    And the "Edit reservation" dialog has closed
    Then I see the following lines in the "Items" section:
      | title     | body   |
      | 4× Kamera | Pool A |

    # submit the order
    When I wait for 1 second
    When I click on "Confirm rental"
    And I see the "Confirm new rental" dialog
    And I enter "My order" in the "Title" field
    And I click on "Confirm"
    And the "Confirm new rental" dialog has closed
    And I accept the "Order submitted" dialog
    And the "Order submitted" dialog has closed
    Then I have been redirected to the orders list

    # approve the order in legacy
    When I visit the orders page of the pool "Pool A"
    Then I approve the order of the user

    # check the new status of the order
    When I visit "/app/borrow/"
    And I open the main menu
    And I click on "My Rentals"
    Then I see the order "My order" under open orders

    # check the content of the order
    When I click on "My order"
    Then I see "0 of 4 items picked up" in the "State" section
    And I see the following lines in the "Items" section:
      | title     | body   |
      | 1× Kamera | Pool A |
      | 1× Kamera | Pool A |
      | 1× Kamera | Pool A |
      | 1× Kamera | Pool A |
