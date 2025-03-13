class UserPasswordReset < Sequel::Model(:user_password_resets)
  many_to_one :user
end

CROCKFORD_BASE_32_ALPHABET = ("0".."9").to_a + ("A".."Z").to_a - ["I", "L", "O", "U"]

FactoryBot.define do
  factory :user_password_reset do
    user
    used_user_param { [user.login, user.email].select(&:present?).sample }
    token { 20.times.map { CROCKFORD_BASE_32_ALPHABET.sample }.join }
    valid_until { DateTime.now.utc + 2.hours }
    created_at { DateTime.now }
  end
end
