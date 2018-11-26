class ProcurementInspector < Sequel::Model(:procurement_category_inspectors)
end

FactoryBot.define do
  factory :procurement_inspector do
  end
end
