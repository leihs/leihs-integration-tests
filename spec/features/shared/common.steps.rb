step "I pry" do
  binding.pry
end

step "I debug :code" do |code|
  eval(code)
end

step "there is an empty database" do
  reset_database
end

step "I click on :txt" do |txt|
  click_on txt
end

step "I click on :target within :win" do |target, win|
  within(win) do
    click_on target
  end
end

step "I select :option from :from" do |option, from|
  select(option, from: from)
end

step "I check :txt" do |txt|
  check txt
end

step "I click on :txt and accept the alert" do |txt|
  accept_alert { click_on txt }
end

step "I enter :value in the :name field" do |value, name|
  fill_in name, with: value
end

step "I go to :url" do |url|
  visit url
end

step "I visit :url" do |url|
  visit url
end

step "I am on :path" do |path|
  expect(page.current_path).to eq path
end

step "I am redirected to :url" do |url|
  wait_until(10){ current_path == url }
end

step "I see the text:" do |txt|
  expect(page).to have_content(txt.to_s.strip())
end

step "I see :txt" do |txt|
  expect(page).to have_content(txt.to_s.strip())
end

step "I log in with the email :email" do |email|
  @current_user = User.find(email: email)
  visit '/'
  click_on 'Login'
  within('.ui-form-signin') do
    step "I enter '#{email}' in the 'user' field"
    find('button[type="submit"]').click
  end
  within('.ui-form-signin') do
    step "I enter 'password' in the 'password' field"
    find('button[type="submit"]').click
  end
end

step "I log in as the user" do
  step "I log in with the email '#{@user.email or @user.login}'"
end

step "user's preferred language is :lang" do |lang|
  l = Language.find(name: lang)
  @user.update(language_locale: l.locale)
end

step "delegation's preferred language is :lang" do |lang|
  l = Language.find(name: lang)
  @delegation.update(language_locale: l.locale)
end

step "user does not have a prefered language" do
  expect(@user.reload.language_locale).to be_nil
end

step "I log out" do
  visit "/my/user/me"
  find(".fa-user-circle").click
  click_on "Logout"
end

step "(I )sleep :n" do |n|
  sleep n.to_f
end

step "I wait for :n second(s)" do |n|
  step "sleep #{n}"
end

step "I eval :code" do |code|
  eval(code)
end

step "I click button :name" do |name|
  click_button(name)
end

step 'there is an error message' do
  page.has_content?(/error/i)
end

step 'I log in as the initial admin' do
  step "I log in with the email '#{@initial_admin.email}'"
end

step 'I log in as the leihs admin' do
  step "I log in with the email '#{@leihs_admin.email}'"
end

step "I fill out the form with:" do |table|
  fill_form_with_table(table)
end

def fill_form_with_table(table)
  table.hashes.each do |row|
    fill_in(row['field'], with: row['value'])
  end
end

step "I wait a little" do
  sleep 1
end
