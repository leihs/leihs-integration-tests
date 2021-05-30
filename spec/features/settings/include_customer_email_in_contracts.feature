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

  # Scenario: Contact email address of the Lender is included in the contract documents
  #   Given there is a user
  #     And the user is customer of some pool
  #     And the user has the email "user@example.com"
  #     And I log in as the user

  #   # Borrow something
  #   # show the contract
  #   # I see the text "Email

  #   # For the cases
  #   # | login | email               | secondary_email   | expected_txt                                  |
  #   # | user1 |                     |                   |                                               |
  #   # | user2 | user2@example.com   |                   | E-Mail user2@example.com                      |
  #   # | user3 | user3@example.com   | user3@example.org | E-Mail user2@example.com / user3@example.org  |
  #   # * same as above but for a delegation => shows delegated_users email
