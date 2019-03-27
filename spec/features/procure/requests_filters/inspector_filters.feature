Feature: Requests' filter for inspector

  Background:
    Given there is an initial admin
    And there are procurement settings
    And there is a budget period "BP requesting phase" in requesting phase
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
    And there is a requester "Requester Two" for "Organization 3" within "Department 2"

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
    ########################################################################### And there is a request with the following data:
    And there is a request with the following data:
      | field                         | value            |
      | Requester                     | Requester Two    |
      | Organization                  | Organization 3   |
      | Budgetperiode                 | BP requesting phase |
      | Kategorie                     | Category 1       |
      | Artikel oder Projekt          | Product I        |
    And there is a request with the following data:
      | field                         | value            |
      | Requester                     | Requester Two    |
      | Organization                  | Organization 3   |
      | Budgetperiode                 | BP inspection phase |
      | Kategorie                     | Category 2       |
      | Artikel oder Projekt          | Product J        |
    And there is a request with the following data:
      | field                         | value            |
      | Requester                     | Requester Two    |
      | Organization                  | Organization 3   |
      | Budgetperiode                 | BP past          |
      | Kategorie                     | Category 3       |
      | Artikel oder Projekt          | Product K        |
      | Priorität des Prüfers         | Zwingend         |

  Scenario: Filters for inspector
    Given there is an inspector for categories:
      | Category 1 |
      | Category 3 |

    When I log in as the inspector

    Then the "nur eigene (als Prüfer)" filter is checked
    And the "nur Kategorien mit Anträgen" filter is checked

    And "Budgetperioden" filter name is "Alle 3 ausgewählt"
    And "Kategorien" filter name is "Alle 2 ausgewählt"

    And "Organisationen" filter name is "Alle 4 ausgewählt"
    And I uncheck all items for "Organisationen" filter
    Then "Organisationen" filter name is "Keine ausgewählt"
    And I see "0 Anträge"
    And I check all items for "Organisationen" filter

    And "Priorität" filter name is "Alle 2 ausgewählt"

    And "Priorität des Prüfers" filter name is "Alle 4 ausgewählt"
    And I uncheck all items for "Priorität des Prüfers" filter
    Then "Priorität des Prüfers" filter name is "Keine ausgewählt"
    And I see "0 Anträge"
    And I check all items for "Priorität des Prüfers" filter

    And "Status Antrag" filter has following checkboxes:
      | Neu                 |
      | Genehmigt           |
      | Teilweise bewilligt |
      | Abgelehnt           |

    When I expand all categories
    Then I see following budget periods:
      | BP requesting phase |
      | BP inspection phase |
      | BP past             |
    And I see "7 Anträge"
    Then I see requests for the following articles:
      | article   | state      |
      | Product A | Neu        |
      | Product I | Neu        |
      | Product C | Neu        |
      | Product D | Teilweise bewilligt |
      | Product E | Genehmigt |
      | Product F | Abgelehnt |
      | Product K | Neu       |

    When I uncheck "Department 1" for "Organisationen" filter
    Then "Organisationen" filter name is "Organization 3, Organization 4"
    And I see "2 Anträge"
    And I see requests for the following articles:
      | article   | state      |
      | Product I | Neu        |
      | Product K | Neu        |
    When I uncheck "Zwingend" for "Priorität des Prüfers" filter
    Then "Priorität des Prüfers" filter name is "Tief, Mittel, Hoch"
    And I see "1 Antrag"
    And I see requests for the following articles:
      | article   | state      |
      | Product I | Neu        |

    And I click on "Filter zurücksetzen"
 
    When I uncheck "nur eigene (als Prüfer)" filter
    And I expand all categories
    And I see "9 Anträge"
    Then I see requests for the following articles:
      | article   | state      |
      | Product A | Neu        |
      | Product B | Neu        |
      | Product I | Neu        |
      | Product J | Neu        |
      | Product C | Neu        |
      | Product D | Teilweise bewilligt |
      | Product E | Genehmigt |
      | Product F | Abgelehnt |
      | Product K | Neu       |

    When I uncheck "nur Kategorien mit Anträgen" filter
    And I expand all categories
    And I see "9 Anträge"
    Then within all budget periods I see the following main categories:
      | Main Category 1 |
      | Main Category 2 |
    Then within all budget periods I see the following categories:
      | Category 1 |
      | Category 2 |
      | Category 3 |
      | Category 4 |
