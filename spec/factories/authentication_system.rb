class AuthenticationSystem < Sequel::Model(:authentication_systems)
end

FactoryBot.define do
  factory :authentication_system do
    name { Faker::Name.last_name }
    id { name.downcase }
    description { Faker::Lorem.sentence }
    priority { 10 }
    enabled { true }

    trait :external do
      type { 'external' }
      external_sign_in_url { 'https://example.com/sign-in' }
      internal_private_key do <<-KEY.strip_heredoc
      -----BEGIN EC PRIVATE KEY-----
      MHcCAQEEIHErTjw8Z1yNisngEuZ5UvBn1qM2goN3Wd1V4Pn3xQeYoAoGCCqGSM49
      AwEHoUQDQgAEzGT0FBI/bvn21TOuLmkzDwzRsIuOyIf9APV7DAZr3fgCqG1wzXce
      MGG42wJIDRduJ9gb3LJiewqzq6VVURvyKQ==
      -----END EC PRIVATE KEY-----
      KEY
      end
      internal_public_key do <<-KEY.strip_heredoc
      -----BEGIN PUBLIC KEY-----
      MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEzGT0FBI/bvn21TOuLmkzDwzRsIuO
      yIf9APV7DAZr3fgCqG1wzXceMGG42wJIDRduJ9gb3LJiewqzq6VVURvyKQ==
      -----END PUBLIC KEY-----
      KEY
      end
      external_public_key do <<-KEY.strip_heredoc
      -----BEGIN PUBLIC KEY-----
      MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEzGT0FBI/bvn21TOuLmkzDwzRsIuO
      yIf9APV7DAZr3fgCqG1wzXceMGG42wJIDRduJ9gb3LJiewqzq6VVURvyKQ==
      -----END PUBLIC KEY-----
      KEY
      end
    end
  end
end
