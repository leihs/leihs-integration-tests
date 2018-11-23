class ProcurementOrganization < Sequel::Model
end

FactoryBot.define do
  factory :procurement_organization do
    name { Faker::Commerce.department }
  end
end
