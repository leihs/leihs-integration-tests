require "spec_helper"
require_relative "shared/list_helpers"

feature "Inventory list manager timeline actions", type: :feature do
  include InventoryListTestHelpers

  let(:search_token) { "IntMgrTimeline" }
  let(:pool) { FactoryBot.create(:inventory_pool, shortname: "IM") }
  let(:building) { FactoryBot.create(:building, name: "Int Mgr Building", code: "IM1") }
  let(:room) { FactoryBot.create(:room, name: "Int Mgr Room", building: building) }
  let(:model) do
    FactoryBot.create(:leihs_model, product: "IntMgrModel #{search_token}", version: "v1")
  end
  let(:package_model) do
    FactoryBot.create(:leihs_model,
      product: "IntMgrPackage #{search_token}",
      version: "v1",
      is_package: true)
  end
  let(:software_model) do
    FactoryBot.create(:leihs_model,
      product: "IntMgrSoftware #{search_token}",
      version: "v1",
      type: "Software")
  end
  let(:option) do
    FactoryBot.create(:option,
      product: "IntMgrOption #{search_token}",
      version: "v1",
      inventory_code: "IM-OPT-#{search_token}",
      inventory_pool: pool,
      price: 10.00)
  end

  before(:each) do
    FactoryBot.create(:user, is_admin: true, admin_protected: true)
    page.driver.browser.manage.window.resize_to(1280, 1200)

    create_timeline_list_items(
      pool: pool,
      room: room,
      model: model,
      package_model: package_model,
      software_model: software_model
    )
  end

  %i[inventory_manager lending_manager].each do |role|
    scenario "shows timeline in edit dropdown for model, package, and software (#{role})" do
      user = FactoryBot.create(:user, language_locale: "en-GB")
      FactoryBot.create(:access_right,
        inventory_pool: pool,
        user: user,
        role: role)

      sign_in_user(user)
      visit "/inventory/#{pool.id}/list?page=1&size=50&with_items=true&retired=false"

      expect(page).to have_content(pool.name, wait: 20)
      find("input[name='search']").set(search_token)
      await_debounce

      expect_manager_timeline_in_edit_dropdown(pool: pool, model: model)
      expect_manager_timeline_in_edit_dropdown(pool: pool, model: package_model)
      expect_manager_timeline_in_edit_dropdown(pool: pool, model: software_model)

      visit "/inventory/#{pool.id}/list?page=1&size=50&retired=false"
      find("input[name='search']").set(search_token)
      await_debounce

      expect_manager_option_row_without_timeline(
        product_label: "#{option.product} #{option.version}"
      )

      within find('[data-row="model"]', text: model.name) do
        expect(page).to have_no_link("Timeline")
      end
    end
  end
end
