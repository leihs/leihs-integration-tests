class User < Sequel::Model
  attr_accessor :password
  one_to_one :procurement_admin
  many_to_one(:delegator_user, class: self)
  many_to_many(:delegation_users,
               left_key: :delegation_id,
               right_key: :user_id,
               class: self,
               join_table: :delegations_users)

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
  trait :base do
    firstname { Faker::Name.first_name }
    lastname { Faker::Name.last_name }
    email { Faker::Internet.email }
    login { email.split('@').first }
    organization { Faker::Lorem.characters(number: 8) }
  end

  factory :user do
    base

    transient do
      password { 'password' }
    end

    after(:create) do |user, trans|
      if trans.password
        pw_hash = database[<<-SQL]
          SELECT crypt(
            #{database.literal(trans.password)},
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

  factory :user_without_password, class: User do
    base
  end

  factory :delegation, class: User do
    transient do
      name { Faker::Team.name }
      responsible { create(:user) }
      members { [] }
    end

    after(:build) do |user, trans|
      user.firstname = trans.name
      user.delegator_user = trans.responsible
    end

    after(:create) do |user, trans|
      trans.members.each do |member|
        user.add_delegation_user(member)
      end
    end
  end
end
