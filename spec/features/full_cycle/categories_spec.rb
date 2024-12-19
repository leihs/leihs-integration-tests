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

  let(:category_name) { Faker::Company.name }
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
      fill_in "name", with: category_name

      attach_file("user-image", "./spec/files/lisp-machine.jpg")
      click_on "Save"

      find(".fa-chart-pie").click
      click_on @ip.name

      click_on "Inventory"

      find(".dropdown-toggle", text: "Add inventory").click
      click_on "Model"

      within("#product") do
        fill_in("model[product]", with: model_name)
      end

      within "#categories" do
        find("input[title=Category]").set(category_name)
        find("input[title=Category]").click.send_keys(:enter)
      end

      click_on "Save Model"

      find(".dropdown-toggle", text: "Add inventory").click
      click_on "Item"

      within "#is_borrowable" do
        choose "is_borrowable_true"
      end

      within("div[data-id=model_id]") do
        fill_in("Model", with: model_name)
        find('input[title="Model"]').click.send_keys(:enter)
      end

      within("div[data-id=building_id]") do
        fill_in("Building", with: "general building (GB)")
        find('input[title="Building"]').click.send_keys(:enter)
      end

      within("div[data-id=room_id]") do
        fill_in("Room", with: "general room")
        find('input[title="Room"]').click.send_keys(:enter)
      end

      click_on "Save Item"

      visit "/borrow"

      within find(".ui-square-image-grid-item", text: category_name) do
        img = find("img")
        expect(img[:src]).to be_present
      end

      visit "/admin/categories/"
      click_on category_name
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

      click_on category_name
      expect(page).to have_content("Delete")
      click_on "Delete"
      within(".modal") do
        click_on "Delete"
      end
      click_on "reset-tree"
      expect(page).not_to have_content(category_name)
    end
  end
end
