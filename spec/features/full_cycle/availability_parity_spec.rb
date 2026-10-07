require "spec_helper"
require "pry"

# Legacy (manage) and borrow must compute the same availability.
# See https://github.com/leihs/leihs/issues/2287
feature "Availability parity legacy vs. borrow" do
  let(:pool) { FactoryBot.create(:inventory_pool) }
  let(:user) { FactoryBot.create(:user) }

  def create_model_with_item
    model = FactoryBot.create(:leihs_model)
    item = FactoryBot.create(:item,
      leihs_model: model,
      responsible: pool,
      owner: pool)
    [model, item]
  end

  def legacy_changes(model)
    page.evaluate_async_script(<<~JS, legacy_availability_url(model))
      const done = arguments[arguments.length - 1]
      fetch(arguments[0], {headers: {Accept: "application/json"}})
        .then(r => r.json())
        .then(json => done(json[0].changes))
    JS
  end

  def legacy_availability_url(model)
    "/manage/#{pool.id}/availabilities.json" \
      "?model_ids[]=#{model.id}&user_id=#{user.id}"
  end

  def legacy_total_on(changes, date)
    changes
      .select { |d, _, _| Date.parse(d) <= date }
      .max_by { |d, _, _| Date.parse(d) }[1]
  end

  def open_borrow_calendar(model)
    visit "/borrow/models/#{model.id}"
    click_on "Add item"
    show_day_quants = find(id: "show-day-quants", visible: :all)
    show_day_quants.click unless show_day_quants.checked?
  end

  # dates must be ascending, the calendar only navigates forward
  def borrow_quantity_on(date)
    find_date_in_borrow_calendar(date)
    find(".rdrDay:not(.rdrDayPassive) .opcal__day-num", exact_text: date.day.to_s)
      .find(:xpath, "..")
      .find(".opcal__day-quantity")
      .text
      .to_i
  end

  def expect_quantities(model, expected)
    changes = legacy_changes(model)
    open_borrow_calendar(model)
    expected.sort.each do |date, quantity|
      expect(legacy_total_on(changes, date)).to eq(quantity), "legacy #{date}"
      expect(borrow_quantity_on(date)).to eq(quantity), "borrow #{date}"
    end
  end

  before :each do
    FactoryBot.create(:user, is_admin: true, admin_protected: true)
    database.transaction do
      Language.find(locale: "de-CH").update(default: false)
      Language.find(locale: "en-GB").update(default: true)
    end

    FactoryBot.create(:access_right,
      role: :inventory_manager,
      user: user,
      inventory_pool: pool)
  end

  scenario "maintenance period, late reservations and time zone" do
    # Maintenance period of 2 open days, the day after the end is a holiday

    maintenance_model, _ = create_model_with_item
    maintenance_model.update(maintenance_period: 2)
    end_date = Date.today + 3.days
    FactoryBot.create(:reservation,
      leihs_model: maintenance_model,
      status: :approved,
      user: user,
      inventory_pool: pool,
      start_date: Date.today + 2.days,
      end_date: end_date)
    FactoryBot.create(:holiday,
      inventory_pool_id: pool.id,
      name: "Maintenance holiday",
      start_date: end_date + 1.day,
      end_date: end_date + 1.day)

    # Approved with assigned item and past end date: not late

    approved_model, approved_item = create_model_with_item
    FactoryBot.create(:reservation,
      leihs_model: approved_model,
      item_id: approved_item.id,
      status: :approved,
      user: user,
      inventory_pool: pool,
      start_date: Date.today - 3.days,
      end_date: Date.yesterday)

    # Signed with past end date: late, blocked for 1 month

    signed_model, signed_item = create_model_with_item
    FactoryBot.create(:reservation, :with_signed_contract,
      leihs_model: signed_model,
      item_id: signed_item.id,
      user: user,
      inventory_pool: pool,
      start_date: Date.today - 3.days,
      end_date: Date.yesterday)

    sign_in_as user, pool

    expect_quantities(maintenance_model,
      Date.today + 1.day => 1,
      end_date => 0,
      end_date + 1.day => 0,
      end_date + 3.days => 0,
      end_date + 4.days => 1)

    expect_quantities(approved_model, Date.tomorrow => 1)

    expect_quantities(signed_model,
      Date.tomorrow => 0,
      Date.today + 1.month => 0,
      Date.today + 1.month + 1.day => 1)

    # Time zone (borrow only, legacy reads it on boot): pick a zone whose
    # date differs from the UTC date during the whole run

    now = Time.now.utc
    utc_today = now.to_date
    zone_ahead = now.hour >= 11
    Setting.first.update(time_zone: zone_ahead ? "Pacific/Kiritimati" : "Etc/GMT+12")
    zone_today = zone_ahead ? utc_today + 1.day : utc_today - 1.day

    tz_model, tz_item = create_model_with_item
    tz_end_date = [utc_today, zone_today].min
    FactoryBot.create(:reservation, :with_signed_contract,
      leihs_model: tz_model,
      item_id: tz_item.id,
      user: user,
      inventory_pool: pool,
      start_date: tz_end_date - 3.days,
      end_date: tz_end_date)

    open_borrow_calendar(tz_model)
    if zone_ahead
      # late in the zone (not yet in UTC)
      expect(borrow_quantity_on(utc_today + 1.day)).to eq 0
    else
      # late in UTC (not yet in the zone)
      expect(borrow_quantity_on(utc_today)).to eq 1
    end
  end
end
