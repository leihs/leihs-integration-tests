require_relative "item_helpers"

def patch_value_name(index)
  "update.#{index}.value"
end

def scroll_and_click(element)
  page.execute_script("arguments[0].scrollIntoView({block: 'center', inline: 'nearest'})", element.native)
  sleep 0.1
  element.click
rescue Selenium::WebDriver::Error::ElementNotInteractableError
  page.execute_script("arguments[0].click()", element.native)
end

def click_add_scan_edit_field
  within find('[id="patch-item-form"]') do
    scroll_and_click(find(:button, text: /Add field|Feld hinzufügen/i, match: :first))
  end
end

def click_patch_field_option(field_name)
  sleep 0.3
  scroll_and_click(find(%([data-test-id="field-options"] [data-value="#{field_name}"]), visible: :all, wait: 10))
end

def dismiss_patch_field_dropdown
  # Escape closes the search-edit bulk dialog; dropdowns close on option click.
  unless page.has_css?('[role="dialog"]', wait: 0.5)
    page.send_keys :escape
  end
  sleep 0.2
end

def click_patch_field_label(label)
  within find('[data-test-id="field-options"]', wait: 5) do
    option = all('[role="option"]', text: label, visible: :all, wait: 5).first ||
      all("span", text: label, visible: :all, wait: 5).first ||
      all(:button, text: label, visible: :all, wait: 5).first
    raise Capybara::ElementNotFound, "patch field option #{label.inspect}" unless option

    scroll_and_click(option)
  end
end

def add_scan_edit_patch_field(index, label)
  click_add_scan_edit_field if index > 0
  within find('[id="patch-item-form"]') do
    click_on "field-select-#{index}"
  end
  sleep 0.3
  click_patch_field_label(label)
  dismiss_patch_field_dropdown
end

def add_search_edit_patch_field(index, field_name)
  click_add_scan_edit_field if index > 0
  within find('[id="patch-item-form"]') do
    click_on "field-select-#{index}"
  end
  click_patch_field_option(field_name)
  dismiss_patch_field_dropdown
end

def fill_scan_edit_text(index, value)
  name = patch_value_name(index)
  within find('[id="patch-item-form"]') do
    field = find("textarea[name='#{name}'], input[name='#{name}']", visible: :all, wait: 5)
    page.execute_script("arguments[0].scrollIntoView({block: 'center', inline: 'nearest'})", field.native)
    field.set(value)
  end
end

def click_scan_edit_radio(index, value)
  scroll_and_click(find(%([data-test-id="#{patch_value_name(index)}-#{value}"]), visible: :all))
end

def click_scan_edit_checkbox(index, value)
  name = patch_value_name(index)
  checkbox_xpath = "//*[@data-test-id=\"#{name}-#{value}\"]"
  scroll_and_click(find(:xpath, checkbox_xpath, visible: :all, wait: 5))
end

def fill_scan_edit_select(index, option_label)
  scroll_and_click(find("button[name='#{patch_value_name(index)}']", visible: :all))
  within("[data-test-id='#{patch_value_name(index)}-options']") do
    find(:button, text: option_label, match: :first).click
  end
  dismiss_patch_field_dropdown
end

def fill_scan_edit_autocomplete(index, search_term, option_text)
  name = patch_value_name(index)
  scroll_and_click(find(%([data-test-id="#{name}"]), visible: :all))
  fill_in "#{name}-input", with: search_term
  scroll_and_click(find(:button, text: option_text, match: :first, wait: 10))
  dismiss_patch_field_dropdown
end

def test_filter_field_id(attr)
  "properties_#{attr}"
end

def select_search_edit_filter_field(index, field_id)
  if index > 0 || !page.has_css?(%([data-test-id="or-0-field-select-#{index}"]), wait: 1)
    find(:button, text: /Add search parameter|Suchparameter hinzufügen/i).click
    expect(page).to have_css(%([data-test-id="or-0-field-select-#{index}"]))
  end
  click_on "or-0-field-select-#{index}"
  expect(page).to have_css('[data-test-id="field-options"]', wait: 10)
  label = field_id.sub(/\Aproperties_/, "")
  if page.has_css?(%([data-test-id="field-options"] [data-value="#{field_id}"]), visible: :all, wait: 2)
    click_patch_field_option(field_id)
  else
    click_patch_field_label(label)
  end
  dismiss_patch_field_dropdown
end

def fill_scan_edit_calendar(index, date)
  field_name = patch_value_name(index)
  debug_calendar("fill_scan_edit_calendar index=#{index} name=#{field_name} date=#{date}")
  scroll_and_click(find("button[name='#{field_name}']", visible: :all))
  expect(page).to have_css("button[data-day]", wait: 10)
  click_calendar_day(date)
end

def set_all_built_in_patch_fields
  values = scan_edit_all_field_values
  date = scan_edit_test_date
  idx = 0

  add_scan_edit_patch_field(idx, "Serial Number")
  fill_scan_edit_text(idx, values[:serial_number])
  idx += 1

  add_scan_edit_patch_field(idx, "MAC-Address")
  fill_scan_edit_text(idx, values[:properties]["mac_address"])
  idx += 1

  add_scan_edit_patch_field(idx, "IMEI-Number")
  fill_scan_edit_text(idx, values[:properties]["imei_number"])
  idx += 1

  add_scan_edit_patch_field(idx, "Name")
  fill_scan_edit_text(idx, values[:name])
  idx += 1

  add_scan_edit_patch_field(idx, "Note")
  fill_scan_edit_text(idx, values[:note])
  idx += 1

  add_scan_edit_patch_field(idx, "Retirement")
  fill_scan_edit_select(idx, "Yes")
  expect(page).to have_content("Reason for Retirement", wait: 5)
  idx += 1
  fill_scan_edit_text(idx, values[:retired_reason])
  idx += 1

  add_scan_edit_patch_field(idx, "Working order")
  click_scan_edit_radio(idx, "true")
  idx += 1

  add_scan_edit_patch_field(idx, "Completeness")
  click_scan_edit_radio(idx, "true")
  idx += 1

  add_scan_edit_patch_field(idx, "Borrowable")
  click_scan_edit_radio(idx, "false")
  idx += 1

  add_scan_edit_patch_field(idx, "Status note")
  fill_scan_edit_text(idx, values[:status_note])
  idx += 1

  add_scan_edit_patch_field(idx, "Relevant for inventory")
  fill_scan_edit_select(idx, "Yes")
  idx += 1

  add_scan_edit_patch_field(idx, "Last Checked")
  fill_scan_edit_calendar(idx, date)
  idx += 1

  add_scan_edit_patch_field(idx, "Responsible person")
  fill_scan_edit_text(idx, values[:responsible])
  idx += 1

  add_scan_edit_patch_field(idx, "User/Typical usage")
  fill_scan_edit_text(idx, values[:user_name])
  idx += 1

  add_scan_edit_patch_field(idx, "Initial Price")
  fill_scan_edit_text(idx, values[:properties]["price"].to_s)
  within find('[id="patch-item-form"]') do
    find("input[name='#{patch_value_name(idx)}']", visible: :all).send_keys :tab
  end
  idx += 1

  add_scan_edit_patch_field(idx, "Supplier")
  fill_scan_edit_autocomplete(idx, values[:supplier_name], values[:supplier_name])
  idx += 1

  add_scan_edit_patch_field(idx, "Reference")
  click_scan_edit_radio(idx, "invoice")
  idx += 1

  add_scan_edit_patch_field(idx, "Invoice Number")
  fill_scan_edit_text(idx, values[:invoice_number])
  idx += 1

  add_scan_edit_patch_field(idx, "Invoice Date")
  fill_scan_edit_calendar(idx, date)
  idx += 1

  add_scan_edit_patch_field(idx, "Warranty expiration")
  fill_scan_edit_calendar(idx, date)
  idx += 1

  add_scan_edit_patch_field(idx, "Contract expiration")
  fill_scan_edit_calendar(idx, date)
  idx += 1

  add_scan_edit_patch_field(idx, "Building")
  fill_scan_edit_autocomplete(idx, values[:building_name], values[:building_name])
  idx += 1

  expect(page).to have_content("Room", wait: 5)
  fill_scan_edit_autocomplete(idx, values[:room_name], values[:room_name])
  idx += 1

  add_scan_edit_patch_field(idx, "Shelf")
  fill_scan_edit_text(idx, values[:shelf])
end
