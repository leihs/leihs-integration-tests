class ProcurementRequest < Sequel::Model
  many_to_one :budget_period, class: ProcurementBudgetPeriod
  many_to_one :category, class: ProcurementCategory
  many_to_one :organization, class: ProcurementOrganization
  many_to_one :user
  many_to_one :room
end

FactoryBot.define do
  factory :procurement_request do
    user
    room
    association :budget_period, factory: :procurement_budget_period
    association :category, factory: :procurement_category
    association :organization, factory: :procurement_organization
    requested_quantity { 1 }
    motivation { Faker::Lorem.sentence }
    article_name { Faker::Commerce.product_name }

    after :build do |r|
      r.organization = ProcurementRequester.find(user: r.user).organization
    end
  end
end
