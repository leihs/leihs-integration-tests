class InventoryPool < Sequel::Model
  one_to_one(:workday)
  one_to_many(:holidays)
end

FactoryBot.define do
  factory :inventory_pool do
    name { Faker::Commerce.department }
    email { Faker::Internet.email }

    after :build do |ip|
      short =
        ip
          .name
          .split(/[\,\s\&]/)
          .select(&:presence)
          .map(&:first)
          .join

      ip.shortname = short
    end

    after(:create) do |ip|
      ip.workday.update(saturday: true, sunday: true)
    end
  end
end
