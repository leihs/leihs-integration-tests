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

step "I am redirected to :url" do |url|
  expect(page.current_path).to eq url
end

step "I see the text:" do |txt|
  expect(page).to have_content(txt.strip())
end
