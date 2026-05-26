require_relative "item_helpers"

module InventoryListTestHelpers
  module_function

  def sign_in_user(user)
    login_as_inventory_user(user)
  end

  def await_debounce
    sleep 0.3
  end

  def dismiss_open_menus
    page.send_keys(:escape)
    page.send_keys(:escape)
    sleep 0.1
  end

  def assert_read_only_inventory_tabs
    expect(page).to have_content("Inventory List", wait: 20)
    within find('[role="tablist"]', wait: 10) do
      expect(page).to have_link("Inventory List")
      expect(page).to have_no_link("Search & Edit", wait: 15)
      expect(page).to have_no_link("Scan & Edit")
      expect(page).to have_no_link("Entitlement Groups")
      expect(page).to have_no_link("Templates")
    end
  end

  def create_timeline_list_items(pool:, room:, model:, package_model:, software_model:)
    FactoryBot.create(:item,
      inventory_code: "#{pool.shortname}001",
      owner_id: pool.id,
      inventory_pool_id: pool.id,
      leihs_model: model,
      room: room,
      shelf: "S-01",
      is_borrowable: true,
      retired: nil)

    FactoryBot.create(:item,
      inventory_code: "#{pool.shortname}002",
      owner_id: pool.id,
      inventory_pool_id: pool.id,
      leihs_model: package_model,
      room: room,
      is_borrowable: true,
      retired: nil)

    FactoryBot.create(:item,
      inventory_code: "#{pool.shortname}003",
      owner_id: pool.id,
      inventory_pool_id: pool.id,
      leihs_model: software_model,
      room: room,
      is_borrowable: true,
      retired: nil)
  end

  def expect_group_manager_timeline_on_model_row(pool:, model:, product_label: nil)
    label = product_label || model.name
    within find('[data-row="model"]', text: label) do
      timeline_link = find(:link, "Timeline")
      expect(timeline_link[:href]).to end_with(
        "/manage/#{pool.id}/models/#{model.id}/timeline"
      )
      expect(timeline_link[:target]).to eq("_blank")
      expect(page).to have_link("Timeline")
      expect(page).not_to have_css('[data-test-id="edit-dropdown"]')
    end
  end

  def expect_no_timeline_on_model_row(product_label:)
    expect(page).to have_css('[data-row="model"]', text: product_label, wait: 10)
    within find('[data-row="model"]', text: product_label) do
      expect(page).to have_no_link("Timeline")
    end
  end

  def expect_no_timeline_in_row(row_element)
    within(row_element) do
      expect(page).to have_no_link("Timeline")
    end
  end

  def expect_manager_option_row_without_timeline(product_label:)
    expect(page).to have_css('[data-row="model"]', text: product_label, wait: 10)
    within find('[data-row="model"]', text: product_label) do
      expect(page).to have_no_link("Timeline")
      expect(page).to have_link("edit")
    end
  end

  def expect_manager_timeline_in_edit_dropdown(pool:, model:, product_label: nil)
    dismiss_open_menus
    label = product_label || model.name
    expect(page).to have_css('[data-row="model"]', text: label, wait: 10)
    within find('[data-row="model"]', text: label) do
      find('[data-test-id="edit-dropdown"]', wait: 10).click
    end
    expect(page).to have_link("Timeline", wait: 10)
    timeline_link = find(:link, "Timeline")
    expect(timeline_link[:href]).to end_with(
      "/manage/#{pool.id}/models/#{model.id}/timeline"
    )
    expect(timeline_link[:target]).to eq("_blank")
    dismiss_open_menus
  end
end
