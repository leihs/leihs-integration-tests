step "the user's email is :email" do |email|
  @user.update(email: email)
end

step "the user's login is :login" do |login|
  @user.update(login: login)
end

step "there is no authentication system enabled for the user" do
  AuthenticationSystemUser.where(user_id: @user.id).delete
end

step "password sign in is disabled for the user" do
  @user.update(password_sign_in_enabled: false)
end

step "the user account is disabled" do
  @user.update(account_enabled: false)
end

step "the user does not have email" do
  @user.update(email: nil)
end

step "there is an error message saying that " \
     "login with this account is not possible" do
  expect(page).to have_content \
    "Anmelden ist mit diesem Benutzerkonto nicht möglich!"
end

step "there is no password authentication system" do
  auth_sys = AuthenticationSystem.find(name: "leihs password")
  AuthenticationSystemUser.where(authentication_system_id: auth_sys.id).destroy
  auth_sys.destroy
end

step "the user has password authentication" do
  expect(AuthenticationSystemUser.where(user_id: @user.id, type: "password")).to be
end

step "there is a password authentication section with a password field" do
  within find("form", text: "Anmelden mit Passwort") do
    find("input#inputPassword")
  end
end

step "there is no password authentication section with a password field" do
  expect(page).not_to have_content "Anmelden mit Passwort"
  expect(page).not_to have_selector "input#inputPassword"
end

step "I am logged in successfully" do
  within ".topnav" do
    expect(current_scope).to have_content "#{@user.firstname.first}#{@user.lastname.first}"
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

step "there is an external authentication section with a button :name" do |name|
  ext_auth_sys = AuthenticationSystem.find(name: name)
  action_url = ["/sign-in/external-authentication/", ext_auth_sys.id, "/request"].join
  within("form[action='#{action_url}']") do
    find("button", text: ext_auth_sys.name)
  end
end

step "I click on the button within the external authentication section" do
  within("form[action='#{@action_url}']") do
    find("button", text: @external_authentication_system.name).click
  end
end

step "I am redirected to the url of that authentication system" do
  expect(current_url).to match(/#{@external_authentication_system.external_sign_in_url}/)
end

step 'I click on "Login" *' do
  # WTF capybara
  # using `*` to distinguish it from common step
  execute_script %( document.querySelector("button.btn-success").click() )
  sleep 1
end

step "there is a forgot password button" do
  find("button", text: "Passwort vergessen?")
end

step "there is a create password button" do
  find("button", text: "Passwort erstellen")
end

step "there is no forgot password button" do
  expect(page).not_to have_selector("button", text: "Passwort vergessen?")
end

step "password sign in is disabled for the user" do
  @user.update(password_sign_in_enabled: false)
end
