require 'config/database.rb'
require 'factory_bot'
require 'faker'

RSpec.configure do |config|

  config.before(:all) do |ctx| 

    Sequel::Model.db = database

    FactoryBot.define do
      to_create { |instance| instance.save }
    end

    config.include FactoryBot::Syntax::Methods

    FactoryBot.find_definitions
  end

  config.before(:each) do
    Faker::UniqueGenerator.clear
  end
end
