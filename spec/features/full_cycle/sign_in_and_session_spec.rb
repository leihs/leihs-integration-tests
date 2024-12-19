require 'spec_helper'
require 'pry'

feature 'sign in and session' do
  scenario 'a signed in user will be signed out if the user_session expires' do
    set_default_locale("en-GB")

    @admin = create_initial_admin
    @admin.update(lastname: Faker::Name.last_name)
    sign_in_as @admin

    SystemAndSecuritySetting.first.update(sessions_max_lifetime_secs: 15)

    find(".fa-circle-user").click
    expect(page).to have_content @admin.lastname
    sleep 15
    visit "/"
    expect(current_path).to eq "/"
    find("button", text: "Login")
  end
end
