class Reservation < Sequel::Model
    STATUSES = [:unsubmitted, :submitted, :rejected, :approved, :signed, :closed]

  many_to_one :user
  many_to_one :inventory_pool
  many_to_one :leihs_model, key: :model_id
end

FactoryBot.define do
  factory :reservation do
    user
    status { :submitted }
    quantity { 1 }
    created_at { DateTime.now }
    updated_at { DateTime.now }
  end
end
