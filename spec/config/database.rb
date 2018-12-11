require 'sequel'

LEIHS_DB_NAME = ENV['LEIHS_DB_NAME'] || 'leihs'
LEIHS_HOST_PORT_POSTGRES = ENV['LEIHS_HOST_PORT_POSTGRES'] || '10054'

def database
  @database ||=
    begin
      db_url =
        ENV['LEIHS_DATABASE_URL'].try(:sub, 'jdbc:', '').presence ||
        "postgresql://root:root@localhost:#{LEIHS_HOST_PORT_POSTGRES}/#{LEIHS_DB_NAME}?max-pool-size=5"
      Sequel.connect(db_url)
    end
end

def reset_database
  database_cleaner
  set_settings_external_base_url
end

private

def database_cleaner
  tables = database[<<-SQL
      SELECT table_name
        FROM information_schema.tables
      WHERE table_type = 'BASE TABLE'
      AND table_schema = 'public'
      AND table_name NOT IN ('schema_migrations','ar_internal_metadata')
      ORDER BY table_type, table_name;
    SQL
  ].map { |r| r[:table_name] }

  database.run "TRUNCATE TABLE #{tables.join(', ')} CASCADE;"
end

def set_settings_external_base_url
  fail unless LEIHS_HTTP_BASE_URL.present?
  database.run "UPDATE settings SET external_base_url='#{LEIHS_HTTP_BASE_URL}'"
end
