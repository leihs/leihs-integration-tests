require "pry"
require "capybara/rspec"
require "selenium-webdriver"
require "turnip/capybara"
require "turnip/rspec"

LEIHS_HTTP_BASE_URL = ENV["LEIHS_HTTP_BASE_URL"].presence || "http://localhost:3200"
LEIHS_HTTP_PORT = Addressable::URI.parse(LEIHS_HTTP_BASE_URL).port.presence || "3200"
BROWSER_WINDOW_SIZE = [1200, 800]
Capybara.app_host = LEIHS_HTTP_BASE_URL
Capybara.test_id = "data-test-id"

# Mirrors bin/env/select-tool-versions-manager: TOOL_VERSIONS_MANAGER wins,
# otherwise mise if available, else asdf. The bin/env/*-setup scripts export
# the variable only within their own process, so rspec cannot rely on it
# (on a mise-only executor this shelled out to `asdf where firefox`).
tool_versions_manager = ENV["TOOL_VERSIONS_MANAGER"].to_s.strip
if tool_versions_manager.empty?
  tool_versions_manager = system("type mise > /dev/null 2>&1") ? "mise" : "asdf"
end
firefox_bin_path = if tool_versions_manager == "mise"
  Pathname.new(`mise where firefox`.strip).join("bin/firefox").expand_path.to_s
else
  Pathname.new(`asdf where firefox`.strip).join("bin/firefox").expand_path.to_s
end
# Only pin the binary when it exists: rspec dry runs (feature-tasks-check)
# never start a browser and may run before firefox-setup installed the
# version from .tool-versions; Selenium raises "not a file" otherwise.
Selenium::WebDriver::Firefox.path = firefox_bin_path if File.file?(firefox_bin_path)

Capybara.register_driver :firefox do |app|
  profile = Selenium::WebDriver::Firefox::Profile.new
  # The legacy contract/document pages call window.print() on load (print=true).
  # While Firefox's print dialog is open the window is not addressable via
  # WebDriver ("Unable to locate window", seen with Firefox 140 ESR under Xvfb
  # on Debian 13 executors): windows.second cannot be switched to or closed.
  # Print silently (no dialog) so the specs can close the contract window.
  profile["print.always_print_silent"] = true
  profile["print.show_print_progress"] = false

  opts = Selenium::WebDriver::Firefox::Options.new(
    # binary: ENV['FIREFOX_ESR_60_PATH'],
    profile: profile,
    log_level: :trace
  )

  # NOTE: good for local dev
  if ENV["LEIHS_TEST_HEADLESS"].present?
    opts.args << "--headless"
  end

  Capybara::Selenium::Driver.new(app, browser: :firefox, options: opts)
end

Capybara.default_driver = :firefox
Capybara.current_driver = :firefox

Capybara.configure do |config|
  config.default_max_wait_time = 15
end
