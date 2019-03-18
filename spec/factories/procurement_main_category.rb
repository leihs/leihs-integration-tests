class ProcurementMainCategory < Sequel::Model
end

FactoryBot.define do
  factory :procurement_main_category do
    name { Faker::Coffee.variety }
  end
end
