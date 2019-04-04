step "the user's email is :email" do |email|
  @user.update(email: email)
end

step "there is no authentication system enabled for the user" do
  AuthenticationSystemUser.where(user_id: @user.id).delete
end

step "there is an error message saying that " \
     "login with this account is not possible" do
  expect(page).to have_content \
    "Anmelden ist mit diesem Benutzerkonto nicht möglich!"
end

step "the user has password authentication" do
  expect(AuthenticationSystemUser.where(user_id: @user.id, type: 'password')).to be
end

step "there is a password authentication section with a password field" do
  within find("form", text: "Anmelden mit Passwort") do
    find("input#inputPassword")
  end
end

step "I am logged in successfully" do
  within "nav.topbar" do
    expect(current_scope).to have_content @user.short_name
  end
end

step "there is an external authentication section with a button" do
  @action_url = ["/sign-in/external-authentication/",
                 @external_authentication_system.id,
                 "/request"].join

  within("form[action='#{@action_url}']") do
    find("button", text: @external_authentication_system.name)
  end
end

step "I click on the button within the external authentication section" do
  # WTF capybara
  execute_script %( document.querySelector("form button").click() )
  sleep 1
  # within("form[action='#{@action_url}']") do
  #   find("button", text: @external_authentication_system.name).click
  # end
end

step "I am redirected to the url of that authentication system" do
  expect(current_url).to match /#{@external_authentication_system.external_url}/
end

step 'I click on "Login" *' do
  # WTF capybara
  # using `*` to distinguish it from common step
  execute_script %( document.querySelector("button.btn-success").click() )
  sleep 1
end
