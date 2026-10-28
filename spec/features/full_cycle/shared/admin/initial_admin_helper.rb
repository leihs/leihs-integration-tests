def create_initial_admin
  visit "/"
  expect(page).to have_content "Initial Admin"
  within "form#initial-admin-form" do
    fill_in "email", with: "admin@example.com"
    fill_in "password", with: "admin-password"
    # Reagent controlled inputs need change events after Capybara fill_in.
    page.execute_script(<<~JS)
      ["initial-admin-email", "password"].forEach(function (id) {
        var el = document.getElementById(id);
        el.dispatchEvent(new Event("input", { bubbles: true }));
        el.dispatchEvent(new Event("change", { bubbles: true }));
      });
    JS
    click_on "Create"
  end
  wait_until(20) { User.where(email: "admin@example.com").first }
  visit "/" if current_path != "/"
  expect(current_path).to be == "/"
  admin = User.where(email: "admin@example.com").first
  admin.password = "admin-password"
  admin
end
