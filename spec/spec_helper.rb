require 'active_support/all'
require 'capybara/rspec'
require 'config/database'
require 'config/factories'
require 'config/metadata_extractor'
require 'config/screenshots'
require 'pry'
require 'selenium-webdriver'
require 'sequel'
require 'turnip/capybara'
require 'turnip/rspec'

BROWSER_WINDOW_SIZE = [ 1200, 800 ]

# FIXME: use https!
LEIHS_HOST_PORT_HTTP = ENV['LEIHS_HOST_PORT_HTTP'] || '10080'
LEIHS_HOST_PORT_HTTPS = ENV['LEIHS_HOST_PORT_HTTPS'] || '10443'
# LEIHS_HTTP_BASE_URL = ENV['LEIHS_HTTP_BASE_URL'] || "https://localhost:#{LEIHS_HOST_PORT_HTTPS}"
LEIHS_HTTP_BASE_URL = ENV['LEIHS_HTTP_BASE_URL'] || "http://localhost:#{LEIHS_HOST_PORT_HTTP}"

# Capybara:
if ENV['FIREFOX_PATH'].present?
  Selenium::WebDriver::Firefox.path = ENV['FIREFOX_PATH']
end
if ENV['FIREFOX_ESR_60_PATH'].present?
  Selenium::WebDriver::Firefox.path = ENV['FIREFOX_ESR_60_PATH']
end


Capybara.register_driver :firefox do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.firefox(
    # TODO: trust the cert used in container and remove this:
    acceptInsecureCerts: true
  )

  profile = Selenium::WebDriver::Firefox::Profile.new
  # TODO: configure language for locale testing
  # profile["intl.accept_languages"] = "en"

  opts = Selenium::WebDriver::Firefox::Options.new(
    # binary: ENV['FIREFOX_ESR_60_PATH'],
    profile: profile,
    log_level: :trace)

  # NOTE: good for local dev
  if ENV['LEIHS_TEST_HEADLESS'].present?
    opts.args << '--headless'
  end
  # opts.args << '--devtools' # NOTE: useful for local debug

  # driver = Selenium::WebDriver.for :firefox, options: opts
  # Capybara::Selenium::Driver.new(app, browser: browser, options: opts)
  Capybara::Selenium::Driver.new(
    app,
    browser: :firefox,
    options: opts,
    desired_capabilities: capabilities
  )
end

# Capybara.run_server = false
Capybara.default_driver = :firefox
Capybara.current_driver = :firefox
Capybara.app_host = LEIHS_HTTP_BASE_URL

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

  config.warnings = false # sequel is just too noisy

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

  config.before(type: :feature) do
    # the shared files lower in the tree are required last
    fp = self.class.superclass.file_path
    bn = File.basename(fp, '.feature')
    dn = File.dirname(fp)

    require_shared_files(dn)

    feature_steps_file = "#{dn}/#{bn}.steps.rb"
    require(feature_steps_file) if File.exist?(feature_steps_file)

    reset_database

    Capybara.current_driver = :firefox

    begin
      # Capybara.current_session.current_window.resize_to(*BROWSER_WINDOW_SIZE)
      page.driver.browser.manage.window.resize_to(*BROWSER_WINDOW_SIZE)
    rescue => e
      fail e
      page.driver.browser.manage.window.maximize
    end
  end

  config.before(pending: true) do |example|
    example.pending
  end

  config.after(type: :feature) do |example|
    page.driver.quit # OPTIMIZE force close browser popups
    Capybara.current_driver = Capybara.default_driver
  end
end

# require files from any shared folders down the directory path
def require_shared_files(dirpath)
  shared_folders = []

  dirpath.split("/").reduce do |acc, el|
    sub_dir = "#{acc}/#{el}"
    shared_folders.push "#{sub_dir}/shared"
    sub_dir
  end

  shared_folders.each do |sf|
    Dir.glob("#{sf}/*.rb") { |f| require f }
  end
end
