Feature: Language

  User has the possibility to switch his or her language. Switching the language in any subapp should have a global effect across all subaps.

  Background:
    Given there is a language "Deutsch" with locale name "de-CH"
    And there is a language "English" with locale name "en-GB"

  Scenario Outline: Switch the language
    Given there is a user with an ultimate access
    And user's preferred language is "Deutsch"
    When I log in as the user
    And I visit "<subapp path>"
    And I change the language to "English"
    Then the language was changed to "English" in the current subapp
    And the language was changed to "English" everywhere
    When I log out
    And I log in as the user
    Then the current language is "English"
    Examples:
      | subapp path       |
      # | /admin/           |
      | /borrow           |
      # | /procure          |
      # | /manage           |
      # | /my               |
