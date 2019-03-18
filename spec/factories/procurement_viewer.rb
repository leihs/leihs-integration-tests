class ProcurementViewer < Sequel::Model(:procurement_category_viewers)
  many_to_one :user
  many_to_one :category, class: ProcurementCategory
end

FactoryBot.define do
  factory :procurement_viewer do
    user
    association :category, factory: :procurement_category
  end
end
