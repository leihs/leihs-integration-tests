class ProcurementRequester < Sequel::Model(:procurement_requesters_organizations)
end

FactoryBot.define do
  factory :procurement_requester do
    organization_id { FactoryBot.create(:procurement_organization).id }
  end
end
