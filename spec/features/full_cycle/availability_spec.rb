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
    # Values apply on blur — tab out after setting.
    date_str = Date.tomorrow.strftime("%d/%m/%Y")
    find("#startDate").set date_str
    find("#endDate").set date_str
    find("#endDate").send_keys(:tab)
    click_on "Add"
    click_on "OK"
    visit "/borrow/order"
    click_on "Send order"
    fill_in "Title", with: Faker::Lorem.sentence
    click_on "Send"
    click_on "OK"

    # Make an overbooking for user_2 in lending

    visit "/manage/#{pool.id}/users/#{user_2.id}/hand_over"
    find(id: "add-end-date").set (Date.tomorrow + 1.day).strftime("%d/%m/%Y")
    # Assign-or-add by inventory code (legacy assign_or_create / include_customer_email):
    # creates the line and assigns in one submit. Avoids model-name + line-assign
    # autocomplete races under Firefox 153.
    add_input = find("#assign-or-add-input input")
    add_input.click
    add_input.set @item.inventory_code
    find("#assign-or-add button[type='submit']").click
    expect(page).to have_css(
      "input[data-assign-item][disabled][value='#{@item.inventory_code}']"
    )
    click_on "Hand Over Selection"
    find(id: "purpose").set Faker::Lorem.sentence
    # Contract.create is async; print_contracts opens a second window after it.
    # Closing windows.second without waiting flakes under Firefox 153 (CI screenshot
    # still on the purpose modal). Same wait as legacy_helpers / include_customer_email.
    within(".modal") { find(".button.green[data-hand-over]", text: "Hand Over").click }
    wait_until { windows.size == 2 }
    windows.second.try(:close)
    switch_to_window(windows.first)
    wait_until { page.has_content?("Finish this hand over") }
    click_on "Finish this hand over"

    # Check the legacy timeline

    visit "/manage/#{pool.id}/models/#{model.id}/old_timeline"

    within find("#timeline-band-1", text: "total") do
      expect(text).to match(/total:\n0\n-1\n0\n1/)
    end

    within find("#timeline-band-2", text: entitlement_group.name) do
      find(".label-no-assigned-item", text: "#{user_1.firstname} #{user_1.lastname} (Quantity: 1)")
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
