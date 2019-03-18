class ProcurementInspector < Sequel::Model(:procurement_category_inspectors)
  many_to_one :user
  many_to_one :category, class: ProcurementCategory
end

FactoryBot.define do
  factory :procurement_inspector do
    user
    association :category, factory: :procurement_category
  end
end
