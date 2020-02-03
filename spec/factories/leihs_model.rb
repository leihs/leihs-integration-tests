class LeihsModel < Sequel::Model(:models)
end

FactoryBot.define do
  factory :leihs_model do
    product { Faker::Commerce.product_name }
    description { Faker::Lorem.paragraph }
    created_at { DateTime.now }
    updated_at { DateTime.now }
  end
end
