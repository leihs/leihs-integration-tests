require "spec_helper"
require "securerandom"
require_relative "shared/list_helpers"

feature "Inventory list read-only pool (group_manager)", type: :feature do
  include InventoryListTestHelpers

  let(:user) { FactoryBot.create(:user, language_locale: "en-GB") }
  let(:pool) { FactoryBot.create(:inventory_pool, shortname: "IntGM") }
  let(:search_token) { "IntGM-Timeline" }
  let(:model) do
    FactoryBot.create(:leihs_model, product: "IntGMModel #{search_token}", version: "v1")
  end
  let(:package_model) do
    FactoryBot.create(:leihs_model,
      product: "IntGMPackage #{search_token}",
      version: "v1",
      is_package: true)
  end
  let(:software_model) do
    FactoryBot.create(:leihs_model,
      product: "IntGMSoftware #{search_token}",
      version: "v1",
      type: "Software")
  end
  let(:rented_package_model) do
    FactoryBot.create(:leihs_model,
      product: "IntGMRentedPkg #{search_token}",
      version: "v1",
      is_package: true)
  end
  let(:option) do
    FactoryBot.create(:option,
      product: "IntGMOption #{search_token}",
      version: "v1",
      inventory_code: "IntGM-OPT-#{search_token}",
      inventory_pool: pool,
      price: 10.00)
  end
  let(:building) { FactoryBot.create(:building, name: "IntGM Building", code: "IG1") }
  let(:room) { FactoryBot.create(:room, name: "IntGM Room", building: building) }

  before(:each) do
    FactoryBot.create(:user, is_admin: true, admin_protected: true)
    page.driver.browser.manage.window.resize_to(1280, 1200)

    FactoryBot.create(:access_right,
      inventory_pool: pool,
      user: user,
      role: :group_manager)

    create_timeline_list_items(
      pool: pool,
      room: room,
      model: model,
      package_model: package_model,
      software_model: software_model
    )

    package_item = FactoryBot.create(:item,
      inventory_code: "#{pool.shortname}004",
      owner_id: pool.id,
      inventory_pool_id: pool.id,
      leihs_model: rented_package_model,
      room: room,
      is_borrowable: true,
      retired: nil)

    borrower = FactoryBot.create(:user)
    contract = Contract.create_with_disabled_triggers(
      SecureRandom.uuid,
      borrower.id,
      pool.id
    )

    FactoryBot.create(:reservation,
      status: :signed,
      leihs_model: rented_package_model,
      item_id: package_item.id,
      contract_id: contract.id,
      user_id: borrower.id,
      inventory_pool_id: pool.id)
  end

  scenario "read-only inventory list with timeline on top-level model rows only" do
    sign_in_user(user)
    visit "/inventory/#{pool.id}/list?page=1&size=50&with_items=true&retired=false"

    expect(page).to have_content(pool.name, wait: 20)

    expect(page).to have_no_selector('[data-test-id="add-inventory-dropdown"]')
    assert_read_only_inventory_tabs

    find("input[name='search']").set(search_token)
    await_debounce

    expect_group_manager_timeline_on_model_row(pool: pool, model: model)
    expect_group_manager_timeline_on_model_row(pool: pool, model: package_model)
    expect_group_manager_timeline_on_model_row(pool: pool, model: software_model)
    expect_group_manager_timeline_on_model_row(pool: pool, model: rented_package_model)

    visit "/inventory/#{pool.id}/list?page=1&size=50&retired=false"
    find("input[name='search']").set(search_token)
    await_debounce

    expect_no_timeline_on_model_row(product_label: "#{option.product} #{option.version}")

    within find('[data-row="model"]', text: model.name) do
      click_on "expand-button"
    end

    expect_no_timeline_in_row(find('[data-row="item"]'))
    within find('[data-row="item"]') do
      expect(page).not_to have_link(href: %r{\.\./items/})
      expect(page).not_to have_css('[data-test-id="edit-dropdown"]')
    end

    within find('[data-row="model"]', text: rented_package_model.name) do
      click_on "expand-button"
    end

    expect_no_timeline_in_row(find('[data-row="package"]'))
  end
end
