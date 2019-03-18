class ProcurementOrganization < Sequel::Model
end

FactoryBot.define do
  factory :procurement_organization do
    name { Faker::Commerce.department }
    parent_id { create(:procurement_department).id }
  end

  factory :procurement_department, class: ProcurementOrganization do
    name { Faker::Commerce.department }
  end
end
