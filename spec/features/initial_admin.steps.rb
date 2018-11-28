step "the /sign-in page is loaded" do
  expect(current_path).to eq "/sign-in"
  expect(page).to have_selector "form[action='/sign-in']"
end

step "I fill out the form with:" do |table|
  within("#initial-admin-form") do
    fill_form_with_table(table)
  end
end

step "I click the button :btn" do |btn|
  click_button(btn)
end

step 'I am logged in as the user "I. Admin"' do
  find("a [data-icon='user-circle']").click
  find(".navbar-leihs .dropdown-menu", text: "I. Admin")
end

step "I see the admin interface" do
  expect(page).to have_selector ".admin"
end

# step :doc_screenshot, 'I document it with a screenshot named ":name"'

def fill_form_with_table(table)
  table.hashes.each do |row|
    fill_in(row['field'], with: row['value'])
  end
end
