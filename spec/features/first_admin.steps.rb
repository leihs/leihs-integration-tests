step "there is an empty database" do
  database_cleaner
end

step "I click on :txt" do |txt|
  click_on txt
end

step "the /sign-in page is loaded" do
  expect(current_path).to eq "/sign-in"
  expect(page).to have_selector "form[action='/sign-in']"
end

step "I enter :value in the :name field" do |value, name|
  fill_in name, with: value
end

step "I go to :url" do |url|
  visit url
end

step "I am redirected to :url" do |url|
  expect(page.current_path).to eq url
end

step "I fill out the form with:" do |table|
  within("#initial-admin-form") do
    fill_form_with_table(table)
  end
end

step "I click the button :btn" do |btn|
  click_button(btn)
end

step 'I am logged in as user with email :email' do |email|
  find("a [data-icon='user-circle']").click
  find(".navbar-leihs .dropdown-menu", text: "admin@leihs.example.com")
end

step "I see the admin interface" do
  expect(page).to have_selector ".admin"
end

step "I see the text:" do |txt|
  expect(page).to have_content(txt.strip())
end

# step :doc_screenshot, 'I document it with a screenshot named ":name"'

def fill_form_with_table(table)
  table.hashes.each do |row|
    fill_in(row['field'], with: row['value'])
  end
end
