require_relative "../../../../../inventory/spec/features/shared/common"

common_helpers_path =
  File.expand_path("../../../../../inventory/spec/features/shared/common.rb", __dir__)
if Object.private_method_defined?(:login) &&
    Object.instance_method(:login).source_location&.first == common_helpers_path
  Object.send(:remove_method, :login)
end

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
  barcode_input = find("input[data-test-id='barcode-input']")
  fill_react_controlled_input(barcode_input, code)
  sleep 0.2
  barcode_input.send_keys(:enter)
end

def expect_scan_edit_success(wait: 60)
  barcode_input = find("input[data-test-id='barcode-input']")

  if page.has_content?(/Item cannot be updated|Gegenstand kann nicht geändert werden/i, wait: 3)
    raise "Scan edit failed: invalid inventory code"
  end
  if page.has_content?(SCAN_EDIT_ERROR_PATTERN, wait: 5)
    detail = all("[data-sonner-toast]", visible: :all, wait: 1).map(&:text).reject(&:empty?).join(" | ")
    raise "Scan edit failed: server rejected the update#{" (#{detail})" unless detail.empty?}"
  end

  wait_until(wait, sleep_secs: 0.3) { barcode_input.value.to_s.blank? }

  return if page.has_css?("[data-sonner-toast]", text: SCAN_EDIT_SUCCESS_PATTERN, wait: 1)
  nil if page.has_content?(SCAN_EDIT_SUCCESS_PATTERN, wait: 1)

  # Barcode cleared after a successful scan even when the toast is ephemeral.
end
