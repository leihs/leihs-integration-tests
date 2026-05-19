require "pry"
require LEIHS_DIR.join("database/spec/config/database")
# require LEIHS_DIR.join("/database/lib/leihs/fields.rb")

RSpec.configure do |config|
  config.before :all do |foo|
    database.extension :pg_json
  end
  config.before :example do |example|
    srand 1
    db_clean
    db_restore_data seeds_sql
    SystemAndSecuritySetting.first.update(external_base_url: LEIHS_HTTP_BASE_URL)
    set_default_locale("de-CH")
    SmtpSetting.first.update(port: smtp_port, address: "localhost", enabled: true)
  end
end

def set_default_locale(locale)
  database.run(<<-SQL.strip_heredoc)
    UPDATE languages AS ls
    SET "default" = vs."default"
    FROM (VALUES ('de-CH', #{(locale == "de-CH") ? "TRUE" : "FALSE"}),
                 ('en-GB', #{(locale == "en-GB") ? "TRUE" : "FALSE"}),
                 ('en-US', #{(locale == "en-US") ? "TRUE" : "FALSE"}),
                 ('gsw-CH', #{(locale == "gsw-CH") ? "TRUE" : "FALSE"}))
              AS vs(locale, "default")
    WHERE vs.locale = ls.locale;
  SQL
end
