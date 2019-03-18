Feature: Request CRUD as procurement admin

  Background:
    Given there is an initial admin
    And there are procurement settings

  Scenario: Inspect a request during inspection phase
    Given there is a budget period "Budget Period BP" in inspection phase
    And there is a main category "Main Category MC1"
    And there is category "Category C1" for main category "Main Category MC1"
    And there is a requester
    And there is a requester "The Requester"
    And there is a procurement admin
    And there is a supplier "Supplier S"
    And there is a building "Building B"
    And there is a room "Room R" for building "Building B"
    And there is a request of requester with the following data:
      | field                         | value            |
      | Budgetperiode                 | Budget Period BP |
      | Kategorie                     | Category C1      |
      | Artikel oder Projekt          | Camera           |
      | Artikelnr. oder Herstellernr. | 12345            |
      | Name des Empfängers           | Hans Heiri       |
      | Begründung                    | And why not      |
      | Priorität                     | Hoch             |
      | Ersatz / Neu                  | Neu              |
      | Stückpreis CHF                | 500              |
      | Menge beantragt               | 10               |
      | Anhänge                       | sicp.pdf         |
    When I log in as the procurement admin
    And I expand the line of the main category "Main Category MC1"
    And I expand the line of the category "Category C"
    And I expand the request line
    When I enter the following data into the request form:
      | field                         | value         |
      | Artikel oder Projekt          | Camera X      |
      | Artikelnr. oder Herstellernr. | 12345 X       |
      | Antragsteller                 | The Requester |
      | Lieferant                     | Supplier S    |
      | Name des Empfängers           | Hans Heiri X  |
      | Begründung                    | And why yes   |
      | Gebäude                       | Building B    |
      | Raum                          | Room R        |
      | Priorität des Prüfers         | Tief          |
      | Kommentar des Prüfers         | Maybe not     |
      | Ersatz / Neu                  | Ersatz        |
      | Stückpreis CHF                | 1000          |
      | Menge bewilligt               | 5             |
      | Bestellmenge                  | 5             |
      | Abrechnungsart                | Investition   |
      | Innenauftrag                  | ABCDEF13245   |
      | Anhänge                       | secd.pdf      |
    And I click on 'Speichern'
    And I expand the request line
    And the request form has the following data: 
      | field                         | value         |
      | Artikel oder Projekt          | Camera X      |
      | Artikelnr. oder Herstellernr. | 12345 X       |
      | Antragsteller                 | The Requester |
      | Lieferant                     | Supplier S    |
      | Name des Empfängers           | Hans Heiri X  |
      | Begründung                    | And why yes   |
      | Priorität                     | Hoch          |
      | Gebäude                       | Building B    |
      | Raum                          | Room R        |
      | Priorität des Prüfers         | Tief          |
      | Kommentar des Prüfers         | Maybe not     |
      | Ersatz / Neu                  | Ersatz        |
      | Stückpreis CHF                | 1000          |
      | Menge beantragt               | 10            |
      | Menge bewilligt               | 5             |
      | Bestellmenge                  | 5             |
      | Abrechnungsart                | Investition   |
      | Innenauftrag                  | ABCDEF13245   |
      | Anhänge                       | secd.pdf      |
