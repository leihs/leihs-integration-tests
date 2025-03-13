require "spec_helper"
require "pry"

feature "Sign in via an external authentication system", type: :feature do
  before :each do
    @test_authentication_system = FactoryBot.create :authentication_system, :external,
      id: "test",
      name: "Test Authentication-System",
      external_sign_in_url: "http://localhost:#{ENV["TEST_AUTH_SYSTEM_PORT"]}/sign-in"

    @admin = FactoryBot.create :user,
      email: "admin@example.com",
      password: "secret",
      admin_protected: true,
      is_admin: true,
      system_admin_protected: true,
      is_system_admin: true

    database[:authentication_systems_users].insert user_id: @admin.id,
      authentication_system_id: @test_authentication_system.id
  end

  scenario "sign in works and audited_changes (of the user_sessions e.g.) are bound to audited_requests" do
    visit "/"
    within(".navbar-leihs form", match: :first) do
      fill_in "user", with: "admin@example.com"
      click_button
    end
    click_on @test_authentication_system.name
    click_on "Yes, I am admin@example.com"

    audited_sign_in_request = database[:audited_requests].order(:created_at).last
    expect(audited_sign_in_request[:path]).to be == "/sign-in/external-authentication/test/sign-in"

    audited_changes = database[:audited_changes].where(txid: [audited_sign_in_request[:txid], audited_sign_in_request[:tx2id]])
    expect(audited_changes).not_to be_empty
    expect(audited_changes.map { |m| m[:table_name] }).to include "user_sessions"
  end
end
