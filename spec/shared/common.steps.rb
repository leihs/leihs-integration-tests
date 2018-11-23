step "I pry" do
  binding.pry
end

step "there is an empty database" do
  database_cleaner
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
  step "I enter '#{email}' in the 'user' field"
  click_on 'Login'
  step "I enter 'password' in the 'password' field"
  click_on 'Weiter'
end

step "I log in as the user" do
  step "I log in with the email '#{@user.email}'"
end
