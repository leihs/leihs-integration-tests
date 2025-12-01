Feature: Inventory - Navigation to Legacy

  Background:
    Given there is an initial admin
    And the default locale is "en-GB"
    And there is a user
    And the user is inventory manager of pool "Pool A"
    And I log in as the user
    And I visit "/inventory/"
    And I open the app menu
    And I click on "Pool A" within "[data-test-id='app-menu']"

  Scenario: Global search
    When I enter "hello" in the global search field and press enter
    Then I see the text:
      """
      Search Results for "hello"
      """

  Scenario: Navigate to lending
    When I click on "Lending"
    Then I see the text:
      """
      Daily View
      """
