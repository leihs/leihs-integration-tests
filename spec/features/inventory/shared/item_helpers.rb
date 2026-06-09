def login_as_inventory_user(user)
  visit "/"
  click_on "Login"
  within(".ui-form-signin") do
    fill_in "user", with: user.login || user.email
    find('button[type="submit"]').click
  end
  within(".ui-form-signin") do
    fill_in "password", with: user.password || "password"
    find('button[type="submit"]').click
  end
  wait_until { current_path != "/" }
end

def assert_field(label, value)
  expect(find_field(label, wait: 10).value).to eq value
end

def assert_checked(el)
  expect(el["data-state"]).to eq "checked"
end

def assert_unchecked(el)
  expect(el["data-state"]).to eq "unchecked"
end

def await_debounce
  sleep 0.3
end

SCAN_EDIT_SUCCESS_PATTERN =
  /Item has been successfully updated|Gegenstand wurde erfolgreich geändert/i

SCAN_EDIT_ERROR_PATTERN =
  /Something went wrong while updating|Beim Ändern ist ein Fehler aufgetreten/i

def fill_react_controlled_input(element, value)
  element.click
  element.send_keys([:control, "a"], :backspace)
  element.send_keys(value)
end

def submit_scan_edit_barcode(code)
  barcode_input = find("input[data-barcode-scanner-target='true']")
  fill_react_controlled_input(barcode_input, code)
  sleep 0.2
  barcode_input.send_keys(:enter)
end

def expect_scan_edit_success(wait: 60)
  barcode_input = find("input[data-barcode-scanner-target='true']")

  if page.has_content?(/Item cannot be updated|Gegenstand kann nicht geändert werden/i, wait: 3)
    raise "Scan edit failed: invalid inventory code"
  end
  if page.has_content?(SCAN_EDIT_ERROR_PATTERN, wait: 5)
    detail = all("[data-sonner-toast]", visible: :all, wait: 1).map(&:text).reject(&:empty?).join(" | ")
    raise "Scan edit failed: server rejected the update#{detail.empty? ? "" : " (#{detail})"}"
  end

  wait_until(wait, sleep_secs: 0.3) { barcode_input.value.to_s.blank? }

  return if page.has_css?("[data-sonner-toast]", text: SCAN_EDIT_SUCCESS_PATTERN, wait: 1)
  nil if page.has_content?(SCAN_EDIT_SUCCESS_PATTERN, wait: 1)

  # Barcode cleared after a successful scan even when the toast is ephemeral.
end

def debug_calendar(message)
  puts "[calendar] #{message}"
end

def dismiss_calendar_popover
  page.send_keys :escape unless page.has_css?('[role="dialog"]', wait: 0.5)
  sleep 0.1
end

def parse_calendar_data_day(value)
  return nil if value.nil? || value.to_s.strip.empty?

  Date.parse(value.to_s)
rescue ArgumentError, TypeError
  # en-US toLocaleDateString (e.g. 6/15/2026) is not parsed by Ruby Date.parse
  if (m = value.to_s.match(%r{\A(\d{1,2})/(\d{1,2})/(\d{4})\z}))
    Date.new(m[3].to_i, m[1].to_i, m[2].to_i)
  else
    debug_calendar("unparsed data-day=#{value.inspect}")
    nil
  end
end

def calendar_day_buttons
  visible = all("button[data-day]", visible: true, wait: 5)
  if visible.any?
    debug_calendar("found #{visible.size} visible data-day button(s)")
    return visible
  end

  all_buttons = all("button[data-day]", visible: :all, wait: 10)
  debug_calendar("no visible data-day buttons; found #{all_buttons.size} in DOM (visible: :all)")
  all_buttons
end

def visible_calendar_month
  buttons = calendar_day_buttons.to_a
  data_days = buttons.map { |btn| btn["data-day"] }
  debug_calendar("data-day values: #{data_days.inspect}") if data_days.any?

  buttons.filter_map do |btn|
    parsed = parse_calendar_data_day(btn["data-day"])
    Date.new(parsed.year, parsed.month, 1) if parsed
  end.last
end

def find_calendar_day_button(date, buttons = nil)
  list = (buttons || calendar_day_buttons).to_a
  match = list.reverse.find do |btn|
    parse_calendar_data_day(btn["data-day"]) == date
  end
  debug_calendar("find day #{date}: #{match ? "matched data-day=#{match["data-day"].inspect}" : "no match"}")
  match
end

def navigate_calendar_toward(date)
  month = visible_calendar_month
  target = Date.new(date.year, date.month, 1)
  unless month
    debug_calendar("navigate: no visible month (no parseable data-day buttons)")
    return
  end

  direction = if target < month
    "previous"
  elsif target > month
    "next"
  end
  if direction
    debug_calendar("navigate #{direction}: visible month #{month}, target #{target}")
    find("[class*=\"rdp-button_#{direction}\"]", wait: 5).click
  else
    debug_calendar("navigate: already on month #{month}")
  end
  sleep 0.15
end

def click_calendar_day(date)
  target_month = Date.new(date.year, date.month, 1)
  debug_calendar("click_calendar_day target=#{date} (#{target_month})")

  12.times do |attempt|
    debug_calendar("attempt #{attempt + 1}/12")
    match = find_calendar_day_button(date)
    if match
      debug_calendar("clicking data-day=#{match["data-day"].inspect}")
      scroll_and_click(match)
      dismiss_calendar_popover
      break :found
    end

    month = visible_calendar_month
    debug_calendar("visible month after search: #{month.inspect}")
    break unless month
    break if month == target_month

    navigate_calendar_toward(date)
  end => result

  return if result == :found

  debug_calendar("FAILED: calendar day #{date} not found after navigation")
  raise Capybara::ElementNotFound, "calendar day #{date}"
end
