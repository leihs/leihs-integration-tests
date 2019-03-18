class ProcurementRequester < Sequel::Model(:procurement_requesters_organizations)
  many_to_one :user
  many_to_one :organization, class: :ProcurementOrganization
end

FactoryBot.define do
  factory :procurement_requester do
    user
    association :organization, factory: :procurement_organization
  end
end
