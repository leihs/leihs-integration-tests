class ProcurementSettings < Sequel::Model(:procurement_settings)
end

FactoryBot.define do
  factory :procurement_settings do
    contact_url { Faker::Internet.url }
    inspection_comments do
      Array(3)
        .map { |_| Faker::Lorem.sentence }
        .to_json
    end
  end
end
