step "I pry" do
  binding.pry
end

step "there is an empty database" do
  reset_database
end

step "I click on :txt" do |txt|
  click_on txt
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

step "I am redirected to :url" do |url|
  binding.pry if url == "?"
  expect(page.current_path).to eq url
end

step "I see the text:" do |txt|
  expect(page).to have_content(txt.strip())
end

step "I log in with the email :email" do |email|
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
  step "I log in with the email '#{@user.email}'"
end

step "user's preferred language is :lang" do |lang|
  l = Language.find(name: lang)
  @user.update(language_id: l.id)
end

step "user does not have a prefered language" do
  expect(@user.language_id).to be_nil
end

step "I log out" do
  visit "/my/user/me"
  find(".fa-user-circle").click
  click_on "Logout"
end
