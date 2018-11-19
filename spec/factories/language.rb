class Language < Sequel::Model
end

FactoryBot.define do
  factory :language do
    name { Faker::Nation.language }
    active { true }
    default { false }

    after :build do |lang|
      unless lang.locale_name
        lang.locale_name = lang.name[0..1].downcase
      end
    end
  end
end
