require 'sequel'
require_relative '../../../legacy/database/lib/leihs/constants'
require '../database/lib/leihs/fields.rb'

def db_name
  ENV['LEIHS_DATABASE_NAME'] || ENV['DB_NAME'] || 'leihs'
end

def db_port
  Integer(ENV['DB_PORT'].presence || ENV['PGPORT'].presence || 5432)
end

def db_con_str
  logger = Logger.new(STDOUT)
  s = 'postgres://' \
    + (ENV['PGUSER'].presence || 'postgres') \
    + ((pw = (ENV['DB_PASSWORD'].presence || ENV['PGPASSWORD'].presence)) ? ":#{pw}" : "") \
    + '@' + (ENV['PGHOST'].presence || 'localhost') \
    + ':' + (db_port).to_s \
    + '/' + (db_name)
  logger.info "SEQUEL CONN #{s}"
  s
end

def database
  @database ||= Sequel.connect(db_con_str)
end

def with_disabled_trigger(table, trigger)
  t_sql = trigger == :all ? 'ALL' : trigger
  database.run "ALTER TABLE #{table} DISABLE TRIGGER #{t_sql}"
  result = yield
  database.run "ALTER TABLE #{table} ENABLE TRIGGER #{t_sql}"
  result
end

def with_disabled_triggers
  database.run 'SET session_replication_role = replica;'
  result = yield
  database.run 'SET session_replication_role = DEFAULT;'
  result
end

def smtp_port
  ENV['LEIHS_MAIL_SMTP_PORT'].presence || raise('LEIHS_MAIL_SMTP_PORT not set')
end

RSpec.configure do |config|
  database.extension :pg_json
  config.before :each  do
    clean_db
    system("LEIHS_DATABASE_NAME=#{db_name} ../database/scripts/restore-seeds")
    load_translations
    set_default_locale('de-CH')
    SystemAndSecuritySetting.first.update(external_base_url: LEIHS_HTTP_BASE_URL)
    SmtpSetting.first.update(port: smtp_port, address: 'localhost', enabled: true)
  end
end

def load_translations
  if ENV['DO_NOT_LOAD_TRANSLATIONS'].presence # due to Matus specific setup
    sql_file = ENV["SQL_FILE"].presence || "../borrow/resources/all/sql/translations.sql" 
    system("psql --quiet -d #{db_name} -f #{sql_file}")
  else
    system("../borrow/bin/get-translations | psql --quiet -d #{db_name}")
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
    AND table_name NOT IN ('schema_migrations', 'ar_internal_metadata', 'default_translations')
    ORDER BY table_type, table_name;
  SQL
  ].map{|r| r[:table_name]}.join(', ').tap do |tables|
    database.run" TRUNCATE TABLE #{tables} CASCADE; "
  end
end
