require 'pry'
require 'active_support/all'
require 'uuidtools'

LEIHS_DIR = Pathname.new(__dir__).join("../..")

require 'config/database'
require 'config/browser'
require 'config/emails'
require 'config/factories'
require 'config/metadata_extractor'
require 'config/screenshots'
require 'config/helpers'

require 'config/rspec'
require 'config/locales'
