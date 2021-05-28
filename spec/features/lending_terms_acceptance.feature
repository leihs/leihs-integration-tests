Feature: Lending Terms acceptance

  For an instance of leihs, lending terms can be configured in form of an external URL.
  If the setting to require acceptance is also set, this URL will be displayed when placing an
  order and customer is required to tick the "I accept" checkbox before submitting.

  Scenario: Configure Lending terms for instance in Admin UI
    Given there is a user with an ultimate access
      And I log in as the user
      Then I see "Admin"

    When I click on "Settings"
      And I click on "Miscellaneous"
      And I click on "Edit"
      And I enter "https://example.org/fileadmin/leihs-terms_2001-01-01.pdf" in the "lending_terms_url" field
      And I check "lending_terms_acceptance_required_for_order"
      And I click on "Save"

    Then the following settings are saved:
      | lending_terms_url                           | https://example.org/fileadmin/leihs-terms_2001-01-01.pdf |
      | lending_terms_acceptance_required_for_order | true                                                     |

  # Scenario: Acceptance of lending terms is enforced when configured
  #   Given there is a user with an ultimate access
  #     And there is a user
  #     And the user is customer of some pool
  #     And I log in as the user

  #   When I pry

