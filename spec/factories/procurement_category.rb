class ProcurementCategory < Sequel::Model
  many_to_one :main_category, class: :ProcurementMainCategory
end

FactoryBot.define do
  factory :procurement_category do
    name { Faker::Coffee.variety }
    association :main_category, factory: :procurement_main_category
  end
end
