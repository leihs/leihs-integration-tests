require "pry"
require "capybara/rspec"
require "selenium-webdriver"
require "turnip/capybara"
require "turnip/rspec"

LEIHS_HTTP_BASE_URL = ENV["LEIHS_HTTP_BASE_URL"].presence || "http://localhost:3200"
LEIHS_HTTP_PORT = Addressable::URI.parse(LEIHS_HTTP_BASE_URL).port.presence || "3200"
BROWSER_WINDOW_SIZE = [1200, 800]
Capybara.app_host = LEIHS_HTTP_BASE_URL

firefox_bin_path = if ENV["TOOL_VERSIONS_MANAGER"] == "mise"
  Pathname.new(`mise where firefox`.strip).join("bin/firefox").expand_path.to_s
else
  Pathname.new(`asdf where firefox`.strip).join("bin/firefox").expand_path.to_s
end

Capybara.register_driver :firefox do |app|
  profile = Selenium::WebDriver::Firefox::Profile.new

  opts = Selenium::WebDriver::Firefox::Options.new
  opts.binary = firefox_bin_path
  opts.profile = profile

  # NOTE: good for local dev
  if ENV["LEIHS_TEST_HEADLESS"].present?
    opts.add_argument("--headless")
  end

  Capybara::Selenium::Driver.new(app, browser: :firefox, options: opts)
end

Capybara.default_driver = :firefox
Capybara.current_driver = :firefox

Capybara.configure do |config|
  config.default_max_wait_time = 15
end
