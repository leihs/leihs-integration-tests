Feature: Release info

  Background:
    Given there is an initial admin

  Scenario: Not logged in
    When I visit "/"
    Then I see the correct release version in the footer
    When I click on the release version link
    Then I am redirected to "/release"
