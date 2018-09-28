require 'capybara/rspec'
require 'turnip/rspec'
require 'turnip/capybara'
require 'selenium-webdriver'
require 'active_support/all'
require 'sequel'
require 'pry'

# Capybara:
if ENV['FIREFOX_PATH'].present?
  Selenium::WebDriver::Firefox.path = ENV['FIREFOX_PATH']
end
if ENV['FIREFOX_ESR_60_PATH'].present?
  Selenium::WebDriver::Firefox.path = ENV['FIREFOX_ESR_60_PATH']
end

[:firefox].each do |browser|
  Capybara.register_driver browser do |app|
    Capybara::Selenium::Driver.new app, browser: browser
  end
end

Capybara.run_server = false
Capybara.current_driver = :selenium
Capybara.app_host = 'http://localhost:10080'

Capybara.configure do |config|
  config.default_max_wait_time = 15
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4.
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  # This option will default to `:apply_to_host_groups` in RSpec 4
  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.disable_monkey_patching!
  config.expose_dsl_globally = true

  config.warnings = true

  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = "doc"
  end

  # make random but reproducable – seed is printed, and can be passed to runit again
  #     --seed 1234
  config.order = :random
  Kernel.srand config.seed

  # Turnip:
  config.raise_error_for_unimplemented_steps = true # TODO: fix
  Dir.glob("spec/**/*.steps.rb") { |f| load f, true }

  config.before(type: :feature) do
    database_cleaner
    Capybara.current_driver = :firefox
    page.driver.browser.manage.window.maximize
  end

  config.after(type: :feature) do |example|
    if ENV['CIDER_CI_TRIAL_ID'].present?
      unless example.exception.nil?
        take_screenshot
      end
    end
    page.driver.quit # OPTIMIZE force close browser popups
    Capybara.current_driver = Capybara.default_driver
    # PgTasks.truncate_tables()
  end

  def take_screenshot(screenshot_dir = nil, name = nil)
    screenshot_dir ||= Rails.root.join('tmp', 'capybara')
    name ||= "screenshot_#{Time.zone.now.iso8601.gsub(/:/, '-')}.png"
    Dir.mkdir screenshot_dir rescue nil
    path = screenshot_dir.join(name)
    case Capybara.current_driver
    when :firefox
      page.driver.browser.save_screenshot(path) rescue nil
    else
      Rails
        .logger
        .warn "Taking screenshots is not implemented for \
      #{Capybara.current_driver}."
    end
  end

end

# test helpers
def wait_until(wait_time = 6, &block)
  Timeout.timeout(wait_time) do
    until value = yield
      sleep(0.2)
    end
    value
  end
rescue Timeout::Error => e
  raise Timeout::Error.new(block.source)
end

# non-test helper methods
def backdoor(cmd)
  `vagrant ssh -- #{Shellwords.escape(cmd)}`
end

def database_cleaner
  db_url = "postgresql://root:root@localhost:10054/leihs?max-pool-size=5"
  database = Sequel.connect(db_url)

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
