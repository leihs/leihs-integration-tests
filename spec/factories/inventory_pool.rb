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

    after :create do |ip|
      MailTemplate.where(is_template_template: true).each do |meta_templ|
        attrs = 
          meta_templ
          .to_hash
          .merge(inventory_pool_id: ip.id, is_template_template: false)
        attrs.delete(:id)

        create(:mail_template, attrs)
      end
    end
  end
end
