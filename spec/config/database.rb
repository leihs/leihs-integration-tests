require 'sequel'
require 'addressable'
require_relative '../../../legacy/database/lib/leihs/constants'
require '../database/lib/leihs/fields.rb'

DB_ENV = ENV['LEIHS_DATABASE_URL'].presence \
  || 'postgresql://leihs:leihs@localhost:5432/leihs?pool=5'

def http_uri
  @http_uri ||= \
    Addressable::URI.parse DB_ENV.gsub(/^jdbc:postgresql/,'http').gsub(/^postgres/,'http')
end

def database
  @database ||= \
    Sequel.connect(
      # trick Addressable to parse db urls
      'postgres://' \
      + (http_uri.user.presence || ENV['PGUSER'].presence || 'postgres') \
      + ((pw = (http_uri.password.presence || ENV['PGPASSWORD'].presence)) ? ":#{pw}" : "") \
      + '@' + (http_uri.host.presence || ENV['PGHOST'].presence || ENV['PGHOSTADDR'].presence || 'localhost') \
      + ':' + (http_uri.port.presence || ENV['PGPORT'].presence || 5432).to_s \
      + '/' + ( http_uri.path.presence.try(:gsub,/^\//,'') || ENV['PGDATABASE'].presence || 'leihs') \
      + '?pool=5')
end

def smtp_port
  ENV['LEIHS_MAIL_SMTP_PORT'].presence || raise('LEIHS_MAIL_SMTP_PORT not set')
end

RSpec.configure do |config|
  database.extension :pg_json
  config.before :each  do
    clean_db
    system("DATABASE_NAME=#{http_uri.basename} ../database/scripts/restore-seeds")
    set_default_locale('de-CH')
    SystemAndSecuritySetting.first.update(external_base_url: LEIHS_HTTP_BASE_URL)
    SmtpSetting.first.update(port: smtp_port, address: 'localhost', enabled: true)
  end
end

def set_default_locale(locale)
  database.run(<<-SQL.strip_heredoc)
    UPDATE languages AS ls
    SET "default" = vs."default"
    FROM (VALUES ('de-CH', #{locale == 'de-CH' ? 'TRUE' : 'FALSE'}),
                 ('en-GB', #{locale == 'en-GB' ? 'TRUE' : 'FALSE'}),
                 ('en-US', #{locale == 'en-US' ? 'TRUE' : 'FALSE'}),
                 ('gsw-CH', #{locale == 'gsw-CH' ? 'TRUE' : 'FALSE'}))
              AS vs(locale, "default")
    WHERE vs.locale = ls.locale;
  SQL
end

def clean_db
  database[ <<-SQL.strip_heredoc
    SELECT table_name
      FROM information_schema.tables
    WHERE table_type = 'BASE TABLE'
    AND table_schema = 'public'
    AND table_name NOT IN ('schema_migrations','ar_internal_metadata')
    ORDER BY table_type, table_name;
            SQL
  ].map{|r| r[:table_name]}.join(', ').tap do |tables|
    database.run" TRUNCATE TABLE #{tables} CASCADE; "
  end
end
