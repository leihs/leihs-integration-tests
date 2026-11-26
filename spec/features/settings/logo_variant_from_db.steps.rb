# Inlined from navbar/shared/common.steps.rb — not on Turnip's shared-step
# lookup path for the settings/ directory.
step "firstname of the user is :name" do |name|
  User.where(id: @user.id).update(firstname: name)
end

step "lastname of the user is :name" do |name|
  User.where(id: @user.id).update(lastname: name)
end

step "the user's locale is :locale" do |locale|
  User.where(id: @user.id).update(language_locale: locale)
end

step "the app logo alt text is :expected" do |expected|
  expect(find('[data-test-id="app-logo"]')[:alt]).to eq expected
end

step "there is an input with id :id" do |id|
  expect(page).to have_css("input##{id}")
end

step "I upload :filename to the input :id" do |filename, id|
  attach_file(id, "#{Dir.pwd}/spec/files/#{filename}")
end

step "in the row :label there is a base64 image" do |label|
  row = find("tr", text: label)
  expect(row).to have_css("img[src^='data:image']")
end

# Firefox 153 + Radix: clicking username text / "Appearance" is flaky (submenu
# needs pointer-enter; leftover menus toggle closed). Use data-test-ids like
# inventory/lending theme specs.
step "I open the inventory theme menu" do
  page.send_keys(:escape)
  expect(page).not_to have_css("[data-test-id='user-menu-content']")

  find("[data-test-id='user-menu']").click
  expect(page).to have_css("[data-test-id='user-menu-content']")
  find("[data-test-id='theme-menu']").click
  expect(page).to have_css("[data-test-id='theme-light']")
  expect(page).to have_css("[data-test-id='theme-dark']")
end

step "I select the inventory theme :theme" do |theme|
  find("[data-test-id='theme-#{theme}']").click
  expect(page).not_to have_css("[data-test-id='user-menu-content']")
end
