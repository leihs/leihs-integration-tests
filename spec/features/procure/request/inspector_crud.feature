Feature: Request CRUD as a inspector

  Background:
    Given there is an initial admin
    And there are procurement settings

  # @pending
  # Scenario: Create a request as an inspector for another user not in one's own category during requesting phase
  #   Given there is a budget period "Budget Period BP" in requesting phase
  #   And there is a main category "Main Category MC1"
  #   And there is category "Category C1" for main category "Main Category MC1"
  #   And there is a main category "Main Category MC2"
  #   And there is category "Category C2" for main category "Main Category MC2"
  #   And there is a requester
  #   And there is an inspector for category "Category C1"
  #   And the inspector is a requester too
  #   When I log in as the inspector
  #   And within the line of the budget period "Budget Period BP" I click on +
  #   And I expand the line of the main category "Main Category MC2"
  #   And within the line of category "Category C2" I click on +

  Scenario: Create a request as an inspector for another user in one's own category during requesting phase
    Given there is a budget period "Budget Period BP" in requesting phase
    And there is a main category "Main Category MC1"
    And there is category "Category C1" for main category "Main Category MC1"
    And there is a main category "Main Category MC2"
    And there is category "Category C2" for main category "Main Category MC2"
    And there is a requester "The Requester"
    And there is an inspector for category "Category C1"
    And the inspector is a requester too
    And there is a supplier "Supplier S"
    And there is a building "Building B"
    And there is a room "Room R" for building "Building B"
    When I log in as the inspector
    And within the line of the budget period "Budget Period BP" I click on +
    And I expand the line of the main category "Main Category MC1"
    And within the line of category "Category C1" I click on +
    When I enter the following data into the request form:
      | field                         | value       |
      | Artikel oder Projekt          | Camera      |
      | Artikelnr. oder Herstellernr. | 12345       |
      | Antragsteller                 | The Requester |
      | Lieferant                     | Supplier S  |
      | Name des Empfängers           | Hans Heiri  |
      | Gebäude                       | Building B  |
      | Raum                          | Room R      |
      | Begründung                    | And why not |
      | Priorität                     | Hoch        |
      | Priorität des Prüfers         | Tief        |
      | Kommentar des Prüfers         | Maybe not   |
      | Ersatz / Neu                  | Neu         |
      | Stückpreis CHF                | 500         |
      | Menge beantragt               | 10          |
      | Menge bewilligt               | 10          |
      | Bestellmenge                  | 10          |
      | Abrechnungsart                | Investition |
      | Innenauftrag                  | ABCDEF13245 |
      | Anhänge                       | secd.pdf    |
    And I click on 'Speichern'
    Then I see a success message
    And the request form has the following data: 
      | field                         | value       |
      | Artikel oder Projekt          | Camera      |
      | Artikelnr. oder Herstellernr. | 12345       |
      | Antragsteller                 | The Requester |
      | Lieferant                     | Supplier S  |
      | Name des Empfängers           | Hans Heiri  |
      | Gebäude                       | Building B  |
      | Raum                          | Room R      |
      | Begründung                    | And why not |
      | Priorität                     | Hoch        |
      | Priorität des Prüfers         | Tief        |
      | Kommentar des Prüfers         | Maybe not   |
      | Ersatz / Neu                  | Neu         |
      | Stückpreis CHF                | 500         |
      | Menge beantragt               | 10          |
      | Menge bewilligt               | 10          |
      | Bestellmenge                  | 10          |
      | Abrechnungsart                | Investition |
      | Innenauftrag                  | ABCDEF13245 |
      | Anhänge                       | secd.pdf    |

  Scenario: Inspect a request during inspection phase
    Given there is a budget period "Budget Period BP" in inspection phase
    And there is a main category "Main Category MC1"
    And there is category "Category C1" for main category "Main Category MC1"
    And there is a requester
    And there is a requester "The Requester"
    And there is an inspector for category "Category C1"
    And there is a supplier "Supplier S"
    And there is a building "Building B"
    And there is a room "Room R" for building "Building B"
    And there is a request of requester with the following data:
      | field                         | value       |
      | Budgetperiode                 | Budget Period BP |
      | Kategorie                     | Category C1 |
      | Artikel oder Projekt          | Camera      |
      | Artikelnr. oder Herstellernr. | 12345       |
      | Name des Empfängers           | Hans Heiri  |
      | Begründung                    | And why not |
      | Priorität                     | Hoch        |
      | Ersatz / Neu                  | Neu         |
      | Stückpreis CHF                | 500         |
      | Menge beantragt               | 10          |
      | Anhänge                       | sicp.pdf    |
    When I log in as the inspector
    And I expand the line of the main category "Main Category MC1"
    And I expand the line of the category "Category C"
    And I expand the request line
    When I enter the following data into the request form:
      | field                         | value       |
      | Artikel oder Projekt          | Camera X    |
      | Artikelnr. oder Herstellernr. | 12345 X     |
      | Antragsteller                 | The Requester |
      | Lieferant                     | Supplier S  |
      | Name des Empfängers           | Hans Heiri X |
      | Gebäude                       | Building B  |
      | Raum                          | Room R      |
      | Priorität des Prüfers         | Tief        |
      | Kommentar des Prüfers         | Maybe not   |
      | Ersatz / Neu                  | Ersatz      |
      | Stückpreis CHF                | 1000        |
      | Menge bewilligt               | 5           |
      | Bestellmenge                  | 5           |
      | Abrechnungsart                | Investition |
      | Innenauftrag                  | ABCDEF13245 |
      | Anhänge                       | secd.pdf    |
    And I click on 'Speichern'
    And I expand the request line
    And the request form has the following data: 
      | field                         | value       |
      | Artikel oder Projekt          | Camera X    |
      | Artikelnr. oder Herstellernr. | 12345 X     |
      | Antragsteller                 | The Requester |
      | Lieferant                     | Supplier S  |
      | Name des Empfängers           | Hans Heiri X |
      | Begründung                    | And why not |
      | Priorität                     | Hoch        |
      | Gebäude                       | Building B  |
      | Raum                          | Room R      |
      | Priorität des Prüfers         | Tief        |
      | Kommentar des Prüfers         | Maybe not   |
      | Ersatz / Neu                  | Ersatz      |
      | Stückpreis CHF                | 1000        |
      | Menge beantragt               | 10          |
      | Menge bewilligt               | 5           |
      | Bestellmenge                  | 5           |
      | Abrechnungsart                | Investition |
      | Innenauftrag                  | ABCDEF13245 |
      | Anhänge                       | secd.pdf    |

  Scenario: Delete someone else's request as an inspector
    Given there is a budget period "Budget Period BP" in inspection phase
    And there is category "Category C"
    And there is a requester
    And there is a request of requester with the following data:
      | field                         | value            |
      | Budgetperiode                 | Budget Period BP |
      | Kategorie                     | Category C       |
    And there is an inspector for category "Category C"
    When I log in as the inspector
    And I uncheck filter option "nur eigene (als Prüfer)"
    And I expand the line of the main category of the category "Category C"
    And I expand the line of the category "Category C"
    And I expand the request line
    Then I see a delete button
    When I click on the delete button and accept the alert
    And I uncheck filter option "nur Kategorien mit Anträgen"
    Then the category "Category C" for budget period "Budget Period BP" is expanded
    And I don't see the request
    And the request was deleted in the database

  Scenario: Move a request to another category
    Given there is a budget period "Budget Period BP" in inspection phase
    And there is category "Category C"
    And there is category "Category D"
    And there is a requester
    And there is a request of requester with the following data:
      | field                         | value            |
      | Budgetperiode                 | Budget Period BP |
      | Kategorie                     | Category C       |
    And there is an inspector for category "Category C"
    When I log in as the inspector
    And I uncheck filter option "nur eigene (als Prüfer)"
    And I expand the line of the main category of the category "Category C"
    And I expand the line of the category "Category C"
    And I expand the request line
    When I click on "Kategorie ändern"
    And I click on "Category D" and accept the alert
    And I expand the line of the main category of the category "Category D"
    And I expand the line of the category "Category D"
    Then I see the article name of the request
    And the category for the request has been updated to "Category D"

  Scenario: Move a request to another budget period
    Given there is a budget period "Budget Period 1" in inspection phase
    Given there is a budget period "Budget Period 2" in requesting phase
    And there is category "Category C"
    And there is a requester
    And there is a request of requester with the following data:
      | field                         | value            |
      | Budgetperiode                 | Budget Period 1  |
      | Kategorie                     | Category C       |
    And there is an inspector for category "Category C"
    When I log in as the inspector
    And I uncheck filter option "nur eigene (als Prüfer)"
    And I expand the line of the main category of the category "Category C"
    And I expand the line of the category "Category C"
    And I expand the request line
    When I click on "Budgetperiode ändern"
    And I click on "Budget Period 2" and accept the alert
    Then I see the article name of the request within budget period "Budget Period 2"
    And I don't see the article name of the request within budget period "Budget Period 1"
    And the budget period for the request has been updated to "Budget Period 2"
