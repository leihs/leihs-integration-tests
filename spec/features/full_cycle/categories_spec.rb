require "spec_helper"
require "pry"

feature "Integration of category images in borrow ", type: :feature do
  before :each do
    @admin = create_initial_admin

    @user = FactoryBot.create(
      :user, is_admin: true,
      admin_protected: true,
      is_system_admin: true,
      system_admin_protected: true
    )

    @ip = FactoryBot.create(:inventory_pool, id: IP_UUID)
    FactoryBot.create(:procurement_admin, user_id: @user.id)
    FactoryBot.create(:access_right,
      user: @user,
      inventory_pool: @ip,
      role: :inventory_manager)
  end

  let(:parent_name) { Faker::Company.name }
  let(:category_name) { Faker::Company.name }
  let(:category_label) { Faker::Company.name }
  let(:model_name) { Faker::Device.model_name }

  context "an admin via the UI " do
    before(:each) {
      set_default_locale("en-GB")
      sign_in_as @user
    }

    scenario "adds image to cateogry in admin and checks borrow" do
      visit "/"

      click_on "Categories"

      click_on "Add Category"
      expect(page).to have_content "Add a Category"
      fill_in "name", with: parent_name
      attach_file("user-image", "./spec/files/lisp-machine.jpg")
      click_on "Save"

      find("nav[role='navigation'] a", text: "Categories").click

      click_on "Add Category"
      expect(page).to have_content "Add a Category"
      fill_in "name", with: category_name
      click_on "Add parent category"

      within(".modal") do
        find("input[placeholder='Search']").set(parent_name)
        first("li", text: parent_name).hover
        click_on "Select"
        find("input[placeholder='Enter Label']").set(category_label)
      end

      click_on "Save"

      find(".fa-chart-pie").click
      click_on @ip.name

      click_on "Inventory"

      find(".dropdown-toggle", text: "Add inventory").click
      click_on "Model"

      within("#product") do
        fill_in("model[product]", with: model_name)
      end

      # Same as legacy manage category_steps: click menu item (Enter is flaky).
      find("#categories input.ui-autocomplete-input").set(category_name)
      find(".ui-menu-item a", match: :first, text: category_name).click
      find("#categories .list-of-lines .line", text: category_name)

      click_on "Save Model"
      expect(page).to have_content("Model saved")

      find(".dropdown-toggle", text: "Add inventory").click
      click_on "Item"

      within "#is_borrowable" do
        choose "is_borrowable_true"
      end

      # Autocomplete needs a menu click; Enter alone is flaky
      # (building id never sticks → dependent room_id field never appears).
      find("input[title='Model']").fill_in with: model_name
      find("ul.ui-autocomplete a").click
      find("input[title='Building']").fill_in with: "general building"
      find("ul.ui-autocomplete a").click
      find("input[title='Room']").fill_in with: "general room"
      find("ul.ui-autocomplete a").click

      click_on "Save Item"
      expect(page).to have_content("Item saved")

      visit "/borrow"
      expect(page).to have_css(".ui-square-image-grid-item", text: parent_name)

      within find(".ui-square-image-grid-item", text: parent_name) do
        img = find("img")
        expect(img[:src]).to be_present
      end

      click_on parent_name
      within(".list-menu") do
        click_on category_label
      end

      find("h1", text: category_label)

      within(".list-menu") do
        expect(current_scope).to have_content(category_label)
        expect(current_scope).not_to have_content(category_name)
      end

      visit "/admin/categories/"
      find("ul.tree li", text: parent_name).find(".fa-plus").click
      click_on category_label
      expect(page).not_to have_content("Delete")

      find(".fa-chart-pie").click
      click_on @ip.name

      click_on "Inventory"
      click_on "Edit Model"

      within("#categories") do
        click_on "Remove"
      end

      click_on "Save Model"

      visit "/admin/categories/"

      find("ul.tree li", text: parent_name).find(".fa-plus").click
      click_on category_label
      expect(page).to have_content("Delete")
      click_on "Delete"
      within(".modal") do
        click_on "Delete"
      end
      click_on "reset-tree"
      expect(page).not_to have_content(category_label)
    end
  end
end
