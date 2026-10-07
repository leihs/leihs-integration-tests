def create_initial_admin
  visit "/"
  expect(page).to have_content "Initial Admin"
  within "form#initial-admin-form" do
    fill_in "email", with: "admin@example.com"
    fill_in "password", with: "admin-password"
    click_on "Create"
  end
  expect(page).to have_current_path("/", ignore_query: true)
  admin = User.where(email: "admin@example.com").first
  admin.password = "admin-password"
  admin
end
