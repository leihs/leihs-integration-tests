require 'sequel'

def database
  @database ||= 
    begin
      db_url =
        ENV['LEIHS_DATABASE_URL'].try(:sub, 'jdbc:', '').presence ||
        "postgresql://root:root@localhost:10054/leihs?max-pool-size=5"
      Sequel.connect(db_url)
    end
end

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
