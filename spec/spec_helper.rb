require 'pry'
require 'active_support/all'

LEIHS_HTTP_BASE_URL = ENV['LEIHS_HTTP_BASE_URL'].presence || 'http://localhost:3200'

require 'config/database'
require 'config/emails'
require 'config/factories'
require 'config/metadata_extractor'
require 'config/screenshots'
require 'config/helpers'

ACCEPTED_FIREFOX_ENV_PATHS = ['FIREFOX_ESR_78_PATH']

# switch to HTTPS ?
LEIHS_HTTP_PORT =  Addressable::URI.parse(LEIHS_HTTP_BASE_URL).port.presence  || '3200'

BROWSER_WINDOW_SIZE = [ 1200, 800 ]

Capybara.app_host = LEIHS_HTTP_BASE_URL


require 'config/rspec'
require 'config/browser'
require 'config/locales'
