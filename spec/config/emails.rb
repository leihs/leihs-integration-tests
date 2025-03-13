require "mail"

def smtp_port
  ENV.fetch("LEIHS_MAIL_SMTP_PORT", "32025")
end

RSpec.configure do |config|
  config.before :suite do
    setup_email_client
  end
  config.before :each do |example|
    empty_mailbox
  end
end

private

def empty_mailbox
  Mail.delete_all
rescue
end

def setup_email_client
  $mail ||=
    Mail.defaults do
      retriever_method(
        :pop3,
        address: ENV.fetch("LEIHS_MAIL_SMTP_ADDRESS", "localhost"),
        port: ENV.fetch("LEIHS_MAIL_POP3_PORT", "32110"),
        user_name: "any",
        password: "any",
        enable_ssl: false
      )
    end
end
