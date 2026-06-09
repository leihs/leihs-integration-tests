step "I go to the scan-edit page of pool :name" do |name|
  @pool ||= InventoryPool.find(name: name)
  visit "/inventory/#{@pool.id}/scan-edit"
  wait_until { current_path.match %r{^/inventory/#{@pool.id}/scan-edit} }
end

step "I add status note :value on the scan-edit form" do |value|
  add_scan_edit_patch_field(0, "Status note")
  fill_scan_edit_text(0, value)
end

step "I scan inventory code :code" do |code|
  barcode_input = find("input[data-barcode-scanner-target='true']")
  barcode_input.set(code)
  barcode_input.send_keys :enter
  if page.has_content?(/Item cannot be updated|Gegenstand kann nicht geändert werden/i, wait: 3)
    raise "Scan edit failed for #{code}"
  end
  expect(page).to have_content(
    /Item has been successfully updated|Gegenstand wurde erfolgreich geändert/i,
    wait: 60
  )
end

step "I select item :code on the scan-edit form" do |code|
  model_name = LeihsModel.find(product: "Test Model").product
  label = "#{code} - #{model_name}"

  find('[data-test-id="item"]').click
  fill_in "item-input", with: code
  expect(page).to have_content(label, wait: 10)
  find("button", text: label).click
end

step "I apply the scan-edit form" do
  find(:button, text: /Apply|Anwenden/i).click
  expect(page).to have_content(
    /Item has been successfully updated|Gegenstand wurde erfolgreich geändert/i,
    wait: 20
  )
end

step "I set all built-in fields on the scan-edit form" do
  set_all_built_in_patch_fields
end
