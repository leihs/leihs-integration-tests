Feature: Request CRUD as a requester

  Background:
    Given there is an initial admin
    And there are procurement settings

  Scenario: Create a request as a requester
    Given there is a budget period in requesting phase
    And there is category
    And there is a requester
    And there is a supplier "Supplier S"
    And there is a building "Building B"
    And there is a room "Room R" for building "Building B"
    When I log in as the requester
    And within the line of the budget period I click on +
    And within the line of the category I click on +
    When I enter the following data into the request form:
      | field                         | value       |
      | Artikel oder Projekt          | Camera      |
      | Artikelnr. oder Herstellernr. | 12345       |
      | Lieferant                     | Supplier S  |
      | Name des Empfängers           | Hans Heiri  |
      | Gebäude                       | Building B  |
      | Raum                          | Room R      |
      | Begründung                    | And why not |
      | Priorität                     | Hoch        |
      | Ersatz / Neu                  | Neu         |
      | Stückpreis CHF                | 500         |
      | Menge beantragt               | 10          |
      | Anhänge                       | secd.pdf    |
    And I click on 'Speichern'
    Then I see a success message
    And the request form has the following data: 
      | field                         | value       |
      | Artikel oder Projekt          | Camera      |
      | Artikelnr. oder Herstellernr. | 12345       |
      | Lieferant                     | Supplier S  |
      | Name des Empfängers           | Hans Heiri  |
      | Gebäude                       | Building B  |
      | Raum                          | Room R      |
      | Begründung                    | And why not |
      | Priorität                     | Hoch        |
      | Ersatz / Neu                  | Neu         |
      | Stückpreis CHF                | 500         |
      | Menge beantragt               | 10          |
      | Anhänge                       | secd.pdf    |

  Scenario: Update a request as a requester
    Given there is a budget period "Budget Period BP" in requesting phase
    And there is category "Category C"
    And there is a requester
    And there is a supplier "Supplier S"
    And there is a building "Building B"
    And there is a room "Room R" for building "Building B"
    And there is a building "Building B X"
    And there is a room "Room R X" for building "Building B X"
    And there is a request of requester with the following data:
      | field                         | value            |
      | Budgetperiode                 | Budget Period BP |
      | Kategorie                     | Category C       |
      | Artikel oder Projekt          | Camera           |
      | Artikelnr. oder Herstellernr. | 12345            |
      | Name des Empfängers           | Hans Heiri       |
      | Gebäude                       | Building B       |
      | Raum                          | Room R           |
      | Begründung                    | And why not      |
      | Priorität                     | Hoch             |
      | Ersatz / Neu                  | Neu              |
      | Stückpreis CHF                | 500              |
      | Menge beantragt               | 10               |
      | Anhänge                       | sicp.pdf         |
    When I log in as the requester
    And I expand the line of the main category of the category "Category C"
    And I expand the line of the category "Category C"
    And I expand the request line
    Then the request form has the following data: 
      | field                         | value       |
      | Artikel oder Projekt          | Camera      |
      | Artikelnr. oder Herstellernr. | 12345       |
      | Name des Empfängers           | Hans Heiri  |
      | Gebäude                       | Building B  |
      | Raum                          | Room R      |
      | Begründung                    | And why not |
      | Priorität                     | Hoch        |
      | Ersatz / Neu                  | Neu         |
      | Stückpreis CHF                | 500         |
      | Menge beantragt               | 10          |
      | Anhänge                       | sicp.pdf    |
    When I enter the following data into the request form:
      | field                         | value       |
      | Artikel oder Projekt          | Camera X    |
      | Artikelnr. oder Herstellernr. | 12345 X     |
      | Lieferant                     | Supplier S  |
      | Name des Empfängers           | Hans Heiri X |
      | Gebäude                       | Building B X  |
      | Raum                          | Room R X     |
      | Begründung                    | And why not X |
      | Priorität                     | Normal      |
      | Ersatz / Neu                  | Ersatz      |
      | Stückpreis CHF                | 999         |
      | Menge beantragt               | 99          |
      | Anhänge                       | secd.pdf    |
    And I click on 'Speichern'
    When I expand the request line
    Then the request form has the following data:
      | field                         | value       |
      | Artikel oder Projekt          | Camera X    |
      | Artikelnr. oder Herstellernr. | 12345 X     |
      | Lieferant                     | Supplier S  |
      | Name des Empfängers           | Hans Heiri X |
      | Gebäude                       | Building B X  |
      | Raum                          | Room R X     |
      | Begründung                    | And why not X |
      | Priorität                     | Normal      |
      | Ersatz / Neu                  | Ersatz      |
      | Stückpreis CHF                | 999         |
      | Menge beantragt               | 99          |
      | Anhänge                       | secd.pdf    |

  Scenario: Delete a request as a requester
    Given there is a budget period "Budget Period BP" in requesting phase
    And there is category "Category C"
    And there is a requester
    And there is a request of requester with the following data:
      | field                         | value            |
      | Budgetperiode                 | Budget Period BP |
      | Kategorie                     | Category C       |
    When I log in as the requester
    And I expand the line of the main category of the category "Category C"
    And I expand the line of the category "Category C"
    And I expand the request line
    Then I see a delete button
    When I click on the delete button and accept the alert
    Then I don't see the main category of the category "Category C"
    And I don't see the request
    And the request was deleted in the database
