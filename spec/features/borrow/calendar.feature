Feature: Borrow Calendar (generates API Data for UI examples)

  Background:
    Given THE TIME IS FIXED TO "2020-04-13T10:39:34.539Z"
    Given there is an initial admin
      And there is a user
      And the user is customer of the pool "Videopool"
    #   And the pool has Workdays, Holidays…
    #   And the pool has a holiday on 4/20


  Scenario: Model reservation calendar
    Given there is some model with some reservations
    Then I log in as the user
    When I fetch the ModelCalendarData from the API
    Then I save this data as an artefact
    Then I look at the calendar in legacy UI
    # And I pry
