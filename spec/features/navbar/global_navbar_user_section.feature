Feature: Global navbar

  The global navbar looks different for each subapp but should contain common entries. The specific subapp links should correspond to the roles of the logged in user and should redirect to the appropriate place.

  Background:
    Given there is an initial admin
    And there is a user with an ultimate access
    And firstname of the user is "Foo"
    And lastname of the user is "Bar"
    And there is a default language "Deutsch" with locale name "de-CH"
    And user's preferred language is "Deutsch"
    And I log in as the user

  Scenario Outline: Links in the user section for all subapps except borrow
    When I visit "<subapp path>"
    And I open the user dropdown for the "<subapp path>"
    Then I see following entries in the user section for the "<subapp path>" :
      | F. Bar          |
      | Benutzerdaten   |
      | Meine Dokumente |
      | Logout          |
    When I click on "Benutzerdaten"
    Then I am redirected to "/borrow/current-user"
    When I visit "<subapp path>"
    And I open the user dropdown for the "<subapp path>"
    And I click on "Meine Dokumente"
    Then I am redirected to "/borrow/current-user"
    Examples:
      | subapp path                                            |
      | /admin/                                                |
      | /procure                                               |
      | /manage/6bf7dc96-2b11-43c1-9f49-c58a5b332517/inventory |
      | /my/user/me                                            |
