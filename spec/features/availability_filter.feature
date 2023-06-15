Feature: Availability Filter

  Use the scenario from https://github.com/leihs/leihs/wiki/Availability and test the model availability filter for several time periods.

  # Same reference reservations dates are used as in /documentation/sources/business_logic, but with relative dates
  # Periods (with their corresponding dates in the documentation):
  # today to today+14      = 27.06. - 11.07.2018 (covering all reference reservations)
  # today and tomorrow     = 27. + 28.06.2018
  # today+2 to today+4     = 29.06. - 01.07.2018
  # today+5 to today+6     = 02. - 03.07.2018
  # today+7 to today+8     = 04. - 05.07.2018
  # today+9 to today+14    = 06. - 11.07.2018

  Background:
    Given there is an initial admin
    And the default locale is "en-GB"

    # Categories, pools, models
    And there is a category "Foto"
    And there is an inventory pool "Fotopool"
    And there is an inventory pool "Filmpool"
    And there is a model "Kamera"
    And the "Kamera" model belongs to category "Foto"
    And there are 4 borrowable items for model "Kamera" in pool "Fotopool"

    # Entitlement groups
    And there is an entitlement group "Fotokurs 101" in pool "Fotopool"
    And the group "Fotokurs 101" is entitled for 2 items of model "Kamera"
    And there is an entitlement group "Fotokurs 201" in pool "Fotopool"
    And the group "Fotokurs 201" is entitled for 1 items of model "Kamera"

    # Given users
    And there is a user "Anna A"
    And the user is customer of pool "Fotopool"
    And the user is member of entitlement group "Fotokurs 101"
    And the user is member of entitlement group "Fotokurs 201"
    And there is a user "Bruno B"
    And the user is member of entitlement group "Fotokurs 201"
    And the user is customer of pool "Fotopool"
    And there is a user "Cecile C"
    And the user is customer of pool "Fotopool"

    # Given reservations (note: the order of their creation has an impact on the attribution to entitlement groups)
    And "Anna A" has a reservation for "Kamera" in pool "Fotopool" from "${Date.yesterday}" to "${8.days.from_now}"
    And "Bruno B" has a reservation for "Kamera" in pool "Fotopool" from "${Date.today}" to "${Date.tomorrow}"
    And "Cecile C" has a reservation for "Kamera" in pool "Fotopool" from "${Date.today}" to "${14.days.from_now}"
    And "Anna A" has a reservation for "Kamera" in pool "Fotopool" from "${5.days.from_now}" to "${6.days.from_now}"

  Scenario: User without entitlement
    When there is a user "Uwe U"
    And the user is customer of pool "Fotopool"
    And I log in as the user

    When I visit "/borrow/"

    # Period 1 / overall
    When I filter by 1 available item from "${Date.today}" to "${14.days.from_now}"
    Then I see "No items found"

    # Period after all existing reservations
    When I filter by 1 available item from "${15.days.from_now}" to "${15.days.from_now}"
    Then I see one model with the title "Kamera"
    When I filter by 2 available items from "${15.days.from_now}" to "${15.days.from_now}"
    Then I see "No items found"

  Scenario: Check Data Setup (Model Timeline)
    Given there is a user "Steffen Staff"
    And the user is lending manager of pool "Fotopool"
    And I log in as the user
    And I click on "Inventory"
    And I classic expand the "Kamera" line
    And I classic open the old manage timeline for the model "Kamera" in the pool "Fotopool"
    And I take a screenshot named "Timeline for Kamera in Fotopool"

  Scenario: User with entitlement
    Given there is a user "Uwe U"
    And the user is customer of pool "Fotopool"
    And the user is member of entitlement group "Fotokurs 201"
    And I log in as the user

    When I visit "/borrow/"

    # Overall
    When I filter by 1 available item from "${Date.today}" to "${14.days.from_now}"
    Then I see "No items found"

    # Period 1
    When I filter by 1 available item from "${Date.today}" to "${Date.tomorrow}"
    Then I see "No items found"

    # Period 2
    When I filter by 1 available item from "${2.days.from_now}" to "${14.days.from_now}"
    Then I see one model with the title "Kamera"
    When I filter by 2 available item from "${2.days.from_now}" to "${14.days.from_now}"
    Then I see "No items found"

    # Period after all existing reservations
    When I filter by 2 available item from "${15.days.from_now}" to "${15.days.from_now}"
    Then I see one model with the title "Kamera"
    When I filter by 3 available items from "${15.days.from_now}" to "${15.days.from_now}"
    Then I see "No items found"

  Scenario: User with even more entitlement
    When there is a user "Uwe U"
    And the user is customer of pool "Fotopool"
    And the user is member of entitlement group "Fotokurs 101"
    And the user is member of entitlement group "Fotokurs 201"
    And I log in as the user

    When I visit "/borrow/"

    # Overall
    When I filter by 1 available item from "${Date.today}" to "${14.days.from_now}"
    Then I see one model with the title "Kamera"
    When I filter by 2 available item from "${Date.today}" to "${14.days.from_now}"
    Then I see "No items found"

    # Period 1
    When I filter by 1 available item from "${Date.today}" to "${Date.tomorrow}"
    Then I see one model with the title "Kamera"
    When I filter by 2 available item from "${Date.today}" to "${Date.tomorrow}"
    Then I see "No items found"

    # Period 2
    When I filter by 2 available item from "${2.days.from_now}" to "${4.days.from_now}"
    Then I see one model with the title "Kamera"
    When I filter by 3 available item from "${2.days.from_now}" to "${4.days.from_now}"
    Then I see "No items found"

    # Period 3
    When I filter by 1 available item from "${5.days.from_now}" to "${6.days.from_now}"
    Then I see one model with the title "Kamera"
    When I filter by 2 available item from "${5.days.from_now}" to "${6.days.from_now}"
    Then I see "No items found"

    # Period 4
    When I filter by 2 available item from "${7.days.from_now}" to "${8.days.from_now}"
    Then I see one model with the title "Kamera"
    When I filter by 3 available item from "${7.days.from_now}" to "${8.days.from_now}"
    Then I see "No items found"

    # Period 5
    When I filter by 3 available item from "${9.days.from_now}" to "${14.days.from_now}"
    Then I see one model with the title "Kamera"
    When I filter by 4 available item from "${9.days.from_now}" to "${14.days.from_now}"
    Then I see "No items found"

    # Period after all existing reservations
    When I filter by 4 available item from "${15.days.from_now}" to "${15.days.from_now}"
    Then I see one model with the title "Kamera"
    When I filter by 5 available items from "${15.days.from_now}" to "${15.days.from_now}"
    Then I see "No items found"

  Scenario: Overbooking

    # Soft overbooking: Lending reserved items for an unentitled user, at the cost of entitlement group "Fotokurs 101".
    # One item is still available, but only for "Fotokurs 201"
    Given "Cecile C" has a reservation for "Kamera" in pool "Fotopool" from "${13.days.from_now}" to "${14.days.from_now}"
    And "Cecile C" has a reservation for "Kamera" in pool "Fotopool" from "${13.days.from_now}" to "${14.days.from_now}"

    When there is a user "Uwe U"
    And the user is customer of pool "Fotopool"
    And I log in as the user

    # When Uwe U is not entitled

    When I visit "/borrow/"
    And I filter by 1 available item from "${13.days.from_now}" to "${14.days.from_now}"
    Then I see "No items found"

    # When Uwe U is entitled in Fotokurs 101
    When the user is member of entitlement group "Fotokurs 101"

    When I visit "/borrow/"
    And I clear ls from the borrow app-db
    And I visit "/borrow/"
    And I filter by 1 available item from "${13.days.from_now}" to "${14.days.from_now}"
    Then I see "No items found"

    # When Uwe U is entitled in Fotokurs 201
    When the user is member of entitlement group "Fotokurs 201"

    When I visit "/borrow/"
    And I clear ls from the borrow app-db
    And I visit "/borrow/"
    And I filter by 1 available item from "${13.days.from_now}" to "${14.days.from_now}"
    Then I see one model with the title "Kamera"

    # Soft overbooking with no item left
    Given "Cecile C" has a reservation for "Kamera" in pool "Fotopool" from "${13.days.from_now}" to "${14.days.from_now}"

    When I visit "/borrow/"
    And I clear ls from the borrow app-db
    And I visit "/borrow/"
    And I filter by 1 available item from "${13.days.from_now}" to "${14.days.from_now}"
    Then I see "No items found"

    # Hard overbooking: Lending reserves one more item than available at all.
    # From the app filter perspective this is rather trivial, the item still is not available.
    Given "Cecile C" has a reservation for "Kamera" in pool "Fotopool" from "${13.days.from_now}" to "${14.days.from_now}"

    When I visit "/borrow/"
    And I clear ls from the borrow app-db
    And I visit "/borrow/"
    And I filter by 1 available item from "${13.days.from_now}" to "${14.days.from_now}"
    Then I see "No items found"

  Scenario: Minimal scenario to reproduce NPE (general group has no borrowable items)

    There need to be two pools at least and it needs to be searched from all pools in order
    to trigger the availability computation for the model for the problematic pool (general
    group has no borrowable items).

    Given there is an inventory pool "Pool A"
    And there is a model "Oppo Earphones Matus"
    And there is 1 borrowable item for model "Oppo Earphones Matus" in pool "Pool A"

    And there is an inventory pool "Pool B"
    And there is 1 not borrowable item for model "Oppo Earphones Matus" in pool "Pool B"

    And there is a user "Nimaai N"
    And the user is customer of pool "Pool B"
    And "Nimaai N" has a reservation for "Oppo Earphones Matus" in pool "Pool B" from "${1.months.from_now}" to "${4.months.from_now}"
    And "Nimaai N" has a reservation for "Oppo Earphones Matus" in pool "Pool B" from "${2.month.from_now}" to "${3.months.from_now}"

    Given there is a user "Matus M"
    And the user is customer of pool "Pool A"
    And the user is customer of pool "Pool B"
    And I log in as the user

    When I visit "/borrow/models?only-available=true&start-date=${Date.today}&end-date=${12.months.from_now.to_date}&quantity=1&term=Matus"
    Then I see one model with the title "Oppo Earphones Matus"
