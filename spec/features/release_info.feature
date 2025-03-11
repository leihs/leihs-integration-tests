Feature: Release info

  Background:
    Given there is an initial admin

  Scenario: Not logged in
    When I visit "/"
    Then I see the correct release version in the footer
