Feature: Setting include_customer_email_in_contracts

  If enabled, the contact email address of the lender will be included in the contract documents.
  
  Scenario: Configure in Admin UI
    Given there is a user with an ultimate access
    And I log in as the user
    Then I see "Admin"

    When I click on "Settings"
    And I click on "Miscellaneous"
    And I click on "Edit"
    And I check "include_customer_email_in_contracts"
    And I click on "Save"

    Then the following settings are saved:
      | include_customer_email_in_contracts | true |

  Scenario Outline: Contact email address of the lender is included in the contract documents
    Given there is an initial admin
    And there is a user
    And user's preferred language is "English (US)"
    And there is an inventory pool "Pool A"
    And the user is lending manager of pool "Pool A"
    And there is a model "Beamer"
    And there is 1 borrowable item for model "Beamer" in pool "Pool A"
    And the user has the email "<email>"
    And the user has the secondary email "<secondary_email>"
    And the following settings exist:
      | include_customer_email_in_contracts | true |
    And I log in as the user

    When I hand over something to myself
    And within the contract I see the email "<expected_txt>"

    Examples:
      | email               | secondary_email   | expected_txt                                  |
      |                     |                   |                                               |
      | user2@example.com   |                   | user2@example.com                             |
      | user3@example.com   | user3@example.org | user3@example.com / user3@example.org         |

    # * same as above but for a delegation => shows delegated_users email
  Scenario Outline: Contact email address of the delegated user is included in the contract documents
    Given there is an initial admin
    And there is a delegation
    And there is a user
    And the user is member of the delegation
    And user's preferred language is "English (US)"
    And there is an inventory pool "Pool A"
    And the user is lending manager of pool "Pool A"
    And the delegation is customer of pool "Pool A"
    And there is a model "Beamer"
    And there is 1 borrowable item for model "Beamer" in pool "Pool A"
    And the user has the email "<email>"
    And the user has the secondary email "<secondary_email>"
    And the following settings exist:
      | include_customer_email_in_contracts | true |
    And I log in as the user

    When I hand over something to my delegation me being the contact person
    And within the contract I see the email "<expected_txt>"

    Examples:
      | email               | secondary_email   | expected_txt                                  |
      |                     |                   |                                               |
      | user2@example.com   |                   | user2@example.com                             |
      | user3@example.com   | user3@example.org | user3@example.com / user3@example.org         |
