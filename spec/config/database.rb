require 'sequel'
require 'addressable'
require_relative '../../../legacy/database/lib/leihs/constants'


def database
  @database ||= \
    Sequel.connect(
      if (db_env = ENV['LEIHS_DATABASE_URL'].presence)
        # trick Addressable to parse db urls
        http_uri = Addressable::URI.parse db_env.gsub(/^jdbc:postgresql/,'http').gsub(/^postgres/,'http')
        db_url = 'postgres://' \
          + (http_uri.user.presence || ENV['PGUSER'].presence || 'postgres') \
          + ((pw = (http_uri.password.presence || ENV['PGPASSWORD'].presence)) ? ":#{pw}" : "") \
          + '@' + (http_uri.host.presence || ENV['PGHOST'].presence || ENV['PGHOSTADDR'].presence || 'localhost') \
          + ':' + (http_uri.port.presence || ENV['PGPORT'].presence || 5432).to_s \
          + '/' + ( http_uri.path.presence.try(:gsub,/^\//,'') || ENV['PGDATABASE'].presence || 'leihs') \
          + '?pool=5'
  else
    'postgresql://leihs:leihs@localhost:5432/leihs?pool=5'
  end
  )
end

def reset_database
  clean_db
  set_settings
  resurrect_general_building
  resurrect_general_room_for_general_building
end

RSpec.configure do |config|
  config.before :each  do
    reset_database
  end
end

private

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


def set_settings
  fail unless LEIHS_HTTP_BASE_URL.present?
  Setting.first || Setting.create # ensure existance!
  database.run "UPDATE settings SET external_base_url='#{LEIHS_HTTP_BASE_URL}'"
end

def resurrect_general_building
  database.run <<-SQL
    INSERT INTO buildings (id, name)
    VALUES ('#{Leihs::Constants::GENERAL_BUILDING_UUID}', 'general building')
  SQL
end

def resurrect_general_room_for_general_building
  database.run <<-SQL
    INSERT INTO rooms (name, building_id, general)
    VALUES ('general room', '#{Leihs::Constants::GENERAL_BUILDING_UUID}', TRUE)
  SQL
end
