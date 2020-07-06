require 'mail'

MAIL_SERVER_POP3_HOST = ENV.fetch('LEIHS_MAIL_SMTP_ADDRESS', 'localhost')
MAIL_SERVER_POP3_PORT = ENV.fetch('LEIHS_MAIL_POP3_PORT')

RSpec.configure do |config|
  config.before :each do
    setup_email_client
    empty_mailbox
  end
end

private

def empty_mailbox
  begin
    Mail.delete_all
  rescue
  end
end

def setup_email_client
  Mail.defaults do
    retriever_method(
      :pop3,
      address: MAIL_SERVER_POP3_HOST,
      port: MAIL_SERVER_POP3_PORT,
      user_name: 'any',
      password: 'any',
      enable_ssl: false
    )
  end
end
