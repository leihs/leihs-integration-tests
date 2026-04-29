Feature: Logo variants from DB

  Background:
    Given there is an initial admin
    And there is a user with an ultimate access
    And firstname of the user is "Test"
    And lastname of the user is "User"
    And the user's locale is "en-GB"
    And I log in as the user

  Scenario: Upload logo variants in admin and verify in inventory
    When I visit "/inventory"
    Then the app logo alt text is "Logo default"

    When I visit "/admin/"
    And I click on "Settings"
    And I click on "Miscellaneous"
    Then I see "Logo Light"
    And I see "Logo Dark"

    When I click on "Edit"
    Then there is an input with id "logo_light"
    And there is an input with id "logo_dark"
    When I upload "zhdk-logo.svg" to the input "logo_light"
    And I upload "zhdk-logo-dark.svg" to the input "logo_dark"
    And I click on "Save"
    Then in the row "Logo Light" there is a base64 image
    And in the row "Logo Dark" there is a base64 image

    When I visit "/inventory"
    And I open the inventory user dropdown
    And I click on "Appearance"
    And I click on "Light"
    Then the app logo alt text is "Logo light"

    When I open the inventory user dropdown
    And I click on "Appearance"
    And I click on "Dark"
    Then the app logo alt text is "Logo dark"
