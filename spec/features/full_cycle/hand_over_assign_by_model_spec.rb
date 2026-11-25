require "spec_helper"

# Dedicated coverage for adding a hand-over line by model name (the path
# availability_spec no longer walks). Assignment uses inventory-code submit on
# assign-or-add — per-line focus→autocomplete races under Firefox 153 while
# Spine re-renders the new line (stale nodes / setupAutocomplete blur no-op).
feature "Hand-over assign by model" do
  let(:pool) { FactoryBot.create(:inventory_pool) }
  let(:manager) { FactoryBot.create(:user) }
  let(:customer) { FactoryBot.create(:user) }
  let(:model) { FactoryBot.create(:leihs_model) }

  before :each do
    # Same as master availability_spec: create the missing admin so "/" shows
    # the password sign-in form instead of /admin/initial-admin.
    FactoryBot.create(:user, is_admin: true, admin_protected: true)
    database.transaction do
      Language.find(locale: "de-CH").update(default: false)
      Language.find(locale: "en-GB").update(default: true)
    end

    FactoryBot.create(:access_right,
      role: :inventory_manager,
      user: manager,
      inventory_pool: pool)
    FactoryBot.create(:access_right,
      role: :customer,
      user: customer,
      inventory_pool: pool)
    @item = FactoryBot.create(:item,
      leihs_model: model,
      responsible: pool,
      owner: pool)
  end

  scenario "add line by model name then assign inventory code" do
    sign_in_as manager, pool

    visit "/manage/#{pool.id}/users/#{customer.id}/hand_over"
    find(id: "add-end-date").set (Date.tomorrow + 1.day).strftime("%d/%m/%Y")

    # Model search is debounced (300ms) + async; wait out the loading spinner
    # before clicking (Firefox 153 races with bare .set → immediate find).
    add_input = find("#assign-or-add-input input")
    add_input.click
    add_input.set model.product
    expect(page).to have_css(".ui-autocomplete", wait: 10)
    expect(page).to have_no_css(".ui-autocomplete .loading-bg-small", wait: 10)
    find(".ui-autocomplete .submenu-scroll strong", text: model.product, wait: 10).click

    expect(page).to have_css(
      "[data-line-type='item_line']",
      text: model.product,
      wait: 10
    )

    # Flash can sit above assign-or-add and swallow the next interaction.
    if page.has_selector?("#flash .fa-times-circle", wait: 2)
      find("#flash .fa-times-circle").click
      expect(page).to have_no_selector("#flash .fa-times-circle")
    end

    add_input = find("#assign-or-add-input input")
    add_input.click
    add_input.set @item.inventory_code
    find("#assign-or-add button[type='submit']").click

    expect(page).to have_css(
      "input[data-assign-item][disabled][value='#{@item.inventory_code}']",
      wait: 10
    )
  end
end
