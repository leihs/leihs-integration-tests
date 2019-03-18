Feature: Requests' filter

  Background:
    Given there is an initial admin
    And there are procurement settings

  Scenario: Filters for requester
    Given there is a budget period "BP requesting phase" in requesting phase
    And there is a budget period "BP inspection phase" in inspection phase
    And there is a budget period "BP past" in past phase
    And there is a main category "Main Category 1"
    And there is category "Category 1" for main category "Main Category 1"
    And there is category "Category 2" for main category "Main Category 1"
    And there is a main category "Main Category 2"
    And there is category "Category 3" for main category "Main Category 2"
    And there is category "Category 4" for main category "Main Category 2"
    And there is a department "Department 1"
    And there is an organization "Organization 1" within "Department 1"
    And there is an organization "Organization 2" within "Department 1"
    And there is a department "Department 2"
    And there is an organization "Organization 3" within "Department 2"
    And there is an organization "Organization 4" within "Department 2"
    And there is a requester "Requester One" for "Organization 1" within "Department 1"
    And there is a requester "Requester Two" for "Organization 1" within "Department 1"

    ############################################################################
    # requests for Requester One
    ############################################################################
    And there is a request with the following data:
      | field                         | value            |
      | Requester                     | Requester One    |
      | Organization                  | Organization 1   |
      | Budgetperiode                 | BP requesting phase |
      | Kategorie                     | Category 1       |
      | Artikel oder Projekt          | Product A        |
      | Menge beantragt               | 1                |
      | Priorität                     | Normal           |
    And there is a request with the following data:
      | field                         | value            |
      | Requester                     | Requester One    |
      | Organization                  | Organization 1   |
      | Budgetperiode                 | BP inspection phase |
      | Kategorie                     | Category 2       |
      | Artikel oder Projekt          | Product B        |
      | Menge beantragt               | 1                |
      | Priorität                     | Normal           |
    And there is a request with the following data:
      | field                         | value            |
      | Requester                     | Requester One    |
      | Organization                  | Organization 1   |
      | Budgetperiode                 | BP past          |
      | Kategorie                     | Category 3       |
      | Artikel oder Projekt          | Product C        |
      | Menge beantragt               | 1                |
      | Priorität                     | Normal           |
    And there is a request with the following data:
      | field                         | value            |
      | Requester                     | Requester One    |
      | Organization                  | Organization 1   |
      | Budgetperiode                 | BP past          |
      | Kategorie                     | Category 3       |
      | Artikel oder Projekt          | Product D        |
      | Menge beantragt               | 2                |
      | Menge bewilligt               | 1                |
      | Priorität                     | Hoch             |
    And there is a request with the following data:
      | field                         | value            |
      | Requester                     | Requester One    |
      | Organization                  | Organization 1   |
      | Budgetperiode                 | BP past          |
      | Kategorie                     | Category 3       |
      | Artikel oder Projekt          | Product E        |
      | Menge beantragt               | 1                |
      | Menge bewilligt               | 1                |
      | Priorität                     | Normal           |
    And there is a request with the following data:
      | field                         | value            |
      | Requester                     | Requester One    |
      | Organization                  | Organization 1   |
      | Budgetperiode                 | BP past          |
      | Kategorie                     | Category 3       |
      | Artikel oder Projekt          | Product F        |
      | Menge beantragt               | 1                |
      | Menge bewilligt               | 0                |
      | Priorität                     | Normal           |

    ############################################################################
    # requests for Requester Two
    ###########################################################################
    And there is a request with the following data:
      | field                         | value            |
      | Requester                     | Requester Two    |
      | Organization                  | Organization 1   |
      | Budgetperiode                 | BP requesting phase |
      | Kategorie                     | Category 1       |
    And there is a request with the following data:
      | field                         | value            |
      | Requester                     | Requester Two    |
      | Organization                  | Organization 1   |
      | Budgetperiode                 | BP inspection phase |
      | Kategorie                     | Category 2       |
    And there is a request with the following data:
      | field                         | value            |
      | Requester                     | Requester Two    |
      | Organization                  | Organization 1   |
      | Budgetperiode                 | BP past          |
      | Kategorie                     | Category 3       |

    When I log in as the requester "Requester One"
    Then I see following budget periods:
      | BP requesting phase |
      | BP inspection phase |
      | BP past             |
    When I expand all categories
    Then I see requests for the following articles:
      | article   | state      |
      | Product A | Neu        |
      | Product B | In Prüfung |
      | Product C | Neu        |
      | Product D | Teilweise bewilligt |
      | Product E | Genehmigt |
      | Product F | Abgelehnt |

    When "Budgetperioden" filter name is "Alle 3 ausgewählt"
    And I uncheck all items for "Budgetperioden" filter
    Then "Budgetperioden" filter name is "Keine ausgewählt"
    And I see "0 Anträge"
    And I check all items for "Budgetperioden" filter
    When "Kategorien" filter name is "Alle 4 ausgewählt"
    And I uncheck all items for "Kategorien" filter
    Then "Kategorien" filter name is "Keine ausgewählt"
    And I see "0 Anträge"
    And I check all items for "Kategorien" filter
    When "Priorität" filter name is "Alle 2 ausgewählt"
    And I uncheck all items for "Priorität" filter
    Then "Priorität" filter name is "Keine ausgewählt"
    And I see "0 Anträge"
    And I check all items for "Priorität" filter

    When I uncheck "Neu" for "Status Antrag" filter
    Then I see "4 Anträge"
    And I see requests for the following articles:
      | article   | state      |
      | Product B | In Prüfung |
      | Product D | Teilweise bewilligt |
      | Product E | Genehmigt |
      | Product F | Abgelehnt |
    When I uncheck "In Prüfung" for "Status Antrag" filter
    Then I see "3 Anträge"
    And I see requests for the following articles:
      | article   | state      |
      | Product D | Teilweise bewilligt |
      | Product E | Genehmigt |
      | Product F | Abgelehnt |
    When I uncheck "Teilweise bewilligt" for "Status Antrag" filter
    Then I see "2 Anträge"
    And I see requests for the following articles:
      | article   | state      |
      | Product E | Genehmigt |
      | Product F | Abgelehnt |
    When I uncheck "Genehmigt" for "Status Antrag" filter
    Then I see "1 Antrag"
    And I see requests for the following articles:
      | article   | state      |
      | Product F | Abgelehnt |
    When I uncheck "Abgelehnt" for "Status Antrag" filter
    Then I see "0 Anträge"


    And I click on "Filter zurücksetzen"

    When I uncheck "BP requesting phase" for "Budgetperioden" filter
    Then "Budgetperioden" filter name is "BP inspection phase, BP past"
    And I see "5 Anträge"
    And I see requests for the following articles:
      | article   | state      |
      | Product B | In Prüfung |
      | Product C | Neu        |
      | Product D | Teilweise bewilligt |
      | Product E | Genehmigt |
      | Product F | Abgelehnt |
    When I uncheck "Category 2" for "Kategorien" filter
    Then "Kategorien" filter name is "Category 1, Category 3, Category 4"
    And I see "4 Anträge"
    And I see requests for the following articles:
      | article   | state      |
      | Product C | Neu        |
      | Product D | Teilweise bewilligt |
      | Product E | Genehmigt |
      | Product F | Abgelehnt |
    When I uncheck "Neu" for "Status Antrag" filter
    And I see "3 Anträge"
    And I see requests for the following articles:
      | article   | state      |
      | Product D | Teilweise bewilligt |
      | Product E | Genehmigt |
      | Product F | Abgelehnt |
    When I uncheck "Hoch" for "Priorität" filter
    Then "Priorität" filter name is "Normal"
    And I see "2 Anträge"
    And I see requests for the following articles:
      | article   | state      |
      | Product E | Genehmigt |
      | Product F | Abgelehnt |

    When I search for "Product E"
    Then I see "1 Antrag"
    And I see requests for the following articles:
      | article   | state      |
      | Product E | Genehmigt  |          

    When I click on "Filter zurücksetzen"
    Then I see following budget periods:
      | BP requesting phase |
      | BP inspection phase |
      | BP past             |
    And I see requests for the following articles:
      | article   | state      |
      | Product A | Neu        |
      | Product B | In Prüfung |
      | Product C | Neu        |
      | Product D | Teilweise bewilligt |
      | Product E | Genehmigt |
      | Product F | Abgelehnt |
