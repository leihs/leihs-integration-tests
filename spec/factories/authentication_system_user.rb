class AuthenticationSystemUser < Sequel::Model(:authentication_systems_users)
  many_to_one :user
  many_to_one :authentication_system
end

FactoryBot.define do
  factory :authentication_system_user do
    authentication_system
    user
  end
end
