class User < Sequel::Model
  one_to_one :procurement_admin

  def name
    "#{firstname} #{lastname}"
  end

  def short_name
    "#{firstname.presence && firstname[0] + '.'} #{lastname}"
      .strip.presence \
    || login.to_s.strip.presence \
    || email
  end
end

FactoryBot.define do
  factory :user do
    firstname { Faker::Name.first_name }
    lastname { Faker::Name.last_name }
    email { Faker::Internet.email }

    after(:create) do |user|
      pw_hash = database[<<-SQL]
        SELECT crypt(
          #{database.literal('password')},
          gen_salt('bf')
        ) AS pw_hash
      SQL
        .first[:pw_hash]

      database[:authentication_systems_users].insert(
        user_id: user.id, 
        authentication_system_id: 'password',
        data: pw_hash
      )
    end
  end
end
