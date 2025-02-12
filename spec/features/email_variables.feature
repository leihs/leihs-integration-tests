Feature: Email template variables

  Email template variables like e.g. `inventory_pool.workdays` and `inventory_pool.holidays` should be 
  rendered consistently accross the sub-apps.

  Background:
    Given there is an inventory pool "Pool X"
    And the inventory pool has the following workdays:
      | day       | info                        | open  |
      | monday    | 8:00 - 12:00, 13:00 - 17:00 | true  |
      | tuesday   | open as per mood            | true  |
      | wednesday | open as per mood            | false |
      | thursday  |                             | true  |
      | friday    |                             | false |
      | saturday  |                             | false |
      | sunday    |                             | false |
    And the inventory pool has the following holidays:
      | name      | start_date           | end_date                    |
      | Holiday 1 | Date.today + 1.week  | Date.today + 1.week + 1.day |
      | Holiday 2 | Date.today + 1.month | Date.today + 1.month        |
    And the inventory pool has received mails enabled
    And there is a model "Model M"
    And there is 1 borrowable item for model "Model M" in pool "Pool X"
    And there is a user with an ultimate access
    And the user's language locale is "en-GB"
    And sending of emails is enabled
    And the default locale is "de-CH"

  Scenario: Email template variables
    When I log in as the user
    And I add "inventory_pool.workdays" variable to the "received" template of locale "de-CH" of the pool
    And I add "inventory_pool.holidays" variable to the "received" template of locale "de-CH" of the pool
    And I add "inventory_pool.workdays" variable to the "submitted" template of locale "en-GB" of the pool
    And I add "inventory_pool.holidays" variable to the "submitted" template of locale "en-GB" of the pool
    And I add "inventory_pool.workdays" variable to the "approved" template of locale "en-GB" of the pool
    And I add "inventory_pool.holidays" variable to the "approved" template of locale "en-GB" of the pool

    When I visit the borrow page for model "Model M"
    And I click on "Add item"
    And as start date I choose the next monday
    And as end date I choose the tuesday after that
    And I click on "Add"
    And I click on "OK"
    And I visit "/borrow/order"
    And I click on "Send order"
    And I enter "Order title" in the "title" field
    And I click on "Send"
    And I click on "OK"

    When I visit the orders page of the pool in legacy
    And I approve the order

    Then the email with subject "[leihs] Bestellung eingetroffen" contains correct workdays according to locale "de-CH"
    And the email with subject "[leihs] Bestellung eingetroffen" contains correct holidays according to locale "de-CH"
    And the email with subject "[leihs] Reservation Submitted" contains correct workdays according to locale "en-GB"
    And the email with subject "[leihs] Reservation Submitted" contains correct holidays according to locale "en-GB"
    And the email with subject "[leihs] Reservation Confirmation" contains correct workdays according to locale "en-GB"
    And the email with subject "[leihs] Reservation Confirmation" contains correct holidays according to locale "en-GB"
