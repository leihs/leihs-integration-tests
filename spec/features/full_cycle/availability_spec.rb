require "spec_helper"
require "pry"

feature "Availability" do
  let(:pool) { FactoryBot.create(:inventory_pool) }
  let(:user_1) { FactoryBot.create(:user) }
  let(:user_2) { FactoryBot.create(:user) }
  let(:model) { FactoryBot.create(:leihs_model) }
  let(:entitlement_group) {
    FactoryBot.create(:entitlement_group,
      inventory_pool: pool)
  }

  before :each do
    FactoryBot.create(:user, is_admin: true, admin_protected: true)
    database.transaction do
      Language.find(locale: "de-CH").update(default: false)
      Language.find(locale: "en-GB").update(default: true)
    end

    FactoryBot.create(:access_right,
      role: :inventory_manager,
      user: user_1,
      inventory_pool: pool)
    FactoryBot.create(:access_right,
      role: :customer,
      user: user_2,
      inventory_pool: pool)
    @item = FactoryBot.create(:item,
      leihs_model: model,
      responsible: pool,
      owner: pool)
    FactoryBot.create(:entitlement,
      leihs_model: model,
      entitlement_group: entitlement_group,
      quantity: 1)

    entitlement_group.add_user(user_1)
  end

  scenario "compare legacy and borrow" do
    sign_in_as user_1, pool

    # Make a borrow order by user_1

    visit "/borrow/models/#{model.id}"
    find("button, a", text: "Add item").click
    find(id: "show-day-quants").click
    # DateRangePicker labels are translated; use stable input ids (same as borrow feature specs).
    # Values apply on blur — tab out after setting. Prefer simulate_typing so React
    # controlled inputs get key events (`.set` alone flakes under FF153).
    date_str = Date.tomorrow.strftime("%d/%m/%Y")
    simulate_typing(find("#startDate"), date_str)
    simulate_typing(find("#endDate"), date_str)
    find("#endDate").send_keys(:tab)
    expect(find("#quantity").value).to be_present
    click_on "Add"
    # GraphQL add / submit are async — use borrow modal helpers (same as borrow specs).
    within(find_ui_modal_dialog(title: "Item added")) do
      find("button.btn-primary").click
    end
    visit "/borrow/order"
    click_on "Send order"
    within(find_ui_modal_dialog(title: "Send order")) do
      fill_in "Title", with: Faker::Lorem.sentence
      find("button.btn-primary").click
    end
    within(find_ui_modal_dialog(title: "Order submitted")) do
      find("button.btn-primary").click
    end

    # Make an overbooking for user_2 in lending

    visit "/manage/#{pool.id}/users/#{user_2.id}/hand_over"
    find(id: "add-end-date").set (Date.tomorrow + 1.day).strftime("%d/%m/%Y")
    # Master-era path: model autocomplete then per-line inventory-code assign
    # (not global assign-or-add by inventory code). FF waits: loading spinner +
    # simulate_typing for React inputs.
    add_input = find("#assign-or-add-input input")
    add_input.click
    simulate_typing(add_input, model.product)
    expect(page).to have_no_selector("form#assign-or-add .loading-bg-small")
    find(".ui-autocomplete strong", text: model.product).click
    line = find("[data-line-type='item_line']", text: model.product, match: :first)
    assign_input = line.find("input[data-assign-item]")
    assign_input.click
    simulate_typing(assign_input, @item.inventory_code)
    find(".ui-menu-item", text: @item.inventory_code).click
    expect(page).to have_css(
      "input[data-assign-item][disabled][value='#{@item.inventory_code}']"
    )
    click_on "Hand Over Selection"
    find(id: "purpose").set Faker::Lorem.sentence
    # Contract.create is async; print_contracts opens a second window after it.
    # Closing windows.second without waiting flakes (CI screenshot
    # still on the purpose modal). Same wait as legacy_helpers / include_customer_email.
    # Fail loudly if the window is missing — do not swallow close via try(:close).
    within(".modal") { find(".button.green[data-hand-over]", text: "Hand Over").click }
    wait_until { windows.size == 2 }
    windows.second.close
    switch_to_window(windows.first)
    wait_until { page.has_content?("Finish this hand over") }

    click_on "Finish this hand over"

    # Check the legacy timeline

    visit "/manage/#{pool.id}/models/#{model.id}/old_timeline"

    within find("#timeline-band-1", text: "total") do
      expect(text).to match(/total:\n0\n-1\n0\n1/)
    end

    within find("#timeline-band-2", text: entitlement_group.name) do
      find(".label-no-assigned-item", text: "#{user_1.firstname} #{user_1.lastname}")
      expect(text).to match(/'#{entitlement_group.name}' :\n1\n0\n1\n1/)
    end

    within find("#timeline-band-3", text: "general") do
      find(".label-without-conflict", text: "#{user_2.firstname} #{user_2.lastname} (#{@item.inventory_code})")
      expect(text).to match(/'general' :\n-1\n-1\n-1\n0/)
    end

    # Check the borrow booking calendar for user_1

    visit "/borrow/models/#{model.id}"
    click_on "Add item"

    expect(
      find_date_in_borrow_calendar(Date.today).find(".opcal__day-quantity").text
    ).to eq "0"
    expect(
      find_date_in_borrow_calendar(Date.tomorrow).find(".opcal__day-quantity").text
    ).to eq "0"
    expect(
      find_date_in_borrow_calendar(Date.tomorrow + 1.day).find(".opcal__day-quantity").text
    ).to eq "0"
    expect(
      find_date_in_borrow_calendar(Date.tomorrow + 2.days).find(".opcal__day-quantity").text
    ).to eq "1"
  end
end
