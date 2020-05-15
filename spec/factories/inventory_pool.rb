class InventoryPool < Sequel::Model
  def after_create
    FactoryBot.create(:workday, inventory_pool_id: self.id)
    super
  end
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
  end
end
