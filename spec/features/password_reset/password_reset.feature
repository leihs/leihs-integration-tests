Feature: Password Reset

  Background:
    Given there is an initial admin
    And the smtp default from address is "noreply@nsa.gov"
    And the following Users exist:
      | name       | login     | email               | password_sign_in  | password |
      | Normin     | normin    | normin@example.com  | TRUE              | password |
      | Hans       | hans      | hans@example.com    | TRUE              |          |
      | Nomailer   | nomailer  | NULL                | TRUE              | password |
      | Externer   | external  | ext@example.com     | FALSE             | password |

  Scenario Outline: Via Email, following the link
    Given I am "<user>"
    And my mailbox is empty
    When I go to "/sign-in"
    And I fill out my "<login_or_email>"
    And I click "Weiter"
    Then I see the "<button_txt>" button
    When I click on "<button_txt>"
    Then I am on "/forgot-password"
    And I see my "<login_or_email>" filled out
    When I click "Weiter"
    Then I see the message "Prüfen Sie Ihren E-Mail-Posteingang!"
    And I receive an email

    # FIXME: check correct email from!
    And the email is from "noreply@nsa.gov"

    And the email has a subject of "Password reset"
    And the email body contains "Password reset click this link"
    And the email body contains the password reset link and token
    When I open the password reset link
    Then I am on "/reset-password"
    And I see my "<login_or_email>" filled out
    And I see the token filled out
    When I fill out a new password in the password field
    And I click "Weiter"
    Then I see the message "erfolgreich gespeichert"
    And I can log in with the new password
    Examples:
      | user   | login_or_email  | button_txt          |
      | Normin | email           | Passwort vergessen? |
      | Normin | login           | Passwort vergessen? | 
      | Hans   | email           | Passwort erstellen  |
      | Hans   | login           | Passwort erstellen  |

  Scenario Outline: Via Email, typing the token manually
    Given I am "Normin"
    And my mailbox is empty
    When I go to "/sign-in"
    And I fill out my "<login_or_email>"
    And I click "Weiter"
    Then I see the login form with a password field
    And I see the "Passwort vergessen?" button
    When I click on "Passwort vergessen?"
    Then I am on "/forgot-password"
    And I see my "<login_or_email>" filled out
    When I click "Weiter"
    Then I see the message "Prüfen Sie Ihren E-Mail-Posteingang!"
    And I receive an email
    And the email is from "noreply@nsa.gov"
    And the email has a subject of "Password reset"
    And the email body contains "Password reset click this link"
    And the email body contains the password reset link and token


    When I click on 'Gehen Sie hierher, um das Passwort mit dem Token in der E-Mail zurückzusetzen!'
    Then I am on "/reset-password"

    When I fill out the secret token
    And I click "Weiter"
    Then I see my "<login_or_email>" filled out
    And I see the token filled out

    When I fill out a new password in the password field
    And I click "Weiter"
    Then I see the message "erfolgreich gespeichert"
    And I can log in with the new password
    Examples:
      | login_or_email  |
      | email           |
      | login           |

  Scenario Outline: Can not start password reset if user can not sign in with password
    Given I am "Externer"
    When I go to "/sign-in"
    And I fill out my "<login_or_email>"
    And I click "Weiter"
    Then I see the message "Benutzerkonto nicht möglich"
    And I dont see the "Passwort vergessen?" button
    Examples:
      | login_or_email  |
      | email           |
      | login           |

  Scenario: Error message on /forgot-password if user has no email in DB
    Given I am "Nomailer"
    When I go to "/sign-in"
    And I fill out my "login"
    And I click "Weiter"
    And I see the "Passwort vergessen?" button
    When I click on "Passwort vergessen?"
    Then I am on "/forgot-password"
    And I see the message "Keine Email-Adresse vorhanden"

  Scenario: Error message on /forgot-password if sending of emails is disabled
    Given I am "Nomailer"
    And sending of emails is disabled
    When I go to "/sign-in"
    And I fill out my "login"
    And I click "Weiter"
    And I see the "Passwort vergessen?" button
    When I click on "Passwort vergessen?"
    Then I am on "/forgot-password"
    And I see the message "Das Versenden von Emails ist zur Zeit deaktiviert"

  Scenario: Fails if the token is invalid
    Given I am "Normin"
    When I go to "/reset-password?token=AAAAAAAAAAAAAAAAAAAA"
    Then I see the message "the token is invalid"

  Scenario: Fails if the token is expired
    Given I am "Normin"
    And I have a current password reset with props "{ valid_until: Time.now - 1.second }"
    When I go to "/reset-password"
    And I fill out the secret token from my current password reset
    And I click "Weiter"
    # TODO: should the error come in the first step already?
    And I fill out a new password in the password field
    And I click "Weiter"
    And I see the message "the token has expired"
