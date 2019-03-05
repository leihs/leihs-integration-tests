Feature: Language

  User has the possibility to switch his or her language.
  This is possible without being logged in (saved in browser),
  or when being logged in (saved in database).
  Switching the language in any subapp affects all subaps.

  Background:
    Given there is a user with an ultimate access
    And there is a language "Deutsch" with locale name "de-CH"
    And there is a language "English" with locale name "en-GB"
    And there is a language "French" with locale name "fr-CH"
    And the default language is "Deutsch"

  Scenario: Default language is used if user has no setting for it
    Given user does not have a prefered language
    When I visit "/"
    Then the used language is the default language
    When I log in as the user
    Then the used language is the default language

  Scenario: Changing the language while logged in updates it in profile
    Given user does not have a prefered language
    When I log in as the user
    Then the used language is the default language
    When I switch the language to "French"
    Then the used language is "French"
    And the saved language in my user profile is "French"

  Scenario: After login the saved language is used
    Given user's preferred language is "English"
    When I visit "/"
    Then the used language is the default language
    When I log in as the user
    Then the used language is "English"
    And the saved language in my user profile is "English"

  Scenario: Changing language before logging in updates it in profile
    Given user's preferred language is "English"
    When I visit "/"
    Then the used language is the default language
    When I switch the language to "French"
    Then the used language is "French"
    When I log in as the user
    Then the used language is "French"
    And the saved language in my user profile is "French"

  Scenario: After logout the saved language is still used
    Given user's preferred language is "English"
    When I log in as the user
    Then the used language is "English"
    When I log out
    Then the saved language in my user profile is "English"

  Scenario Outline: Switching the language when logged in applies it for all subapps.
    Given user's preferred language is "French"
    When I log in as the user
    And I visit "<subapp path>"
    And I change the language to "English" in "<subapp path>"
    Then the language was changed to "English" in "<subapp path>"
    And the language was changed to "English" everywhere
    When I log out
    And I log in as the user
    Then the current language is "English"
    Examples:
      | subapp path       |
      | /admin/           |
      | /borrow           |
      | /procure          |
      | /manage           |
      | /my               |
