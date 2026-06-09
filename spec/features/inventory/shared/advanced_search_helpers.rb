ADVANCED_SEARCH_CODES = %w[ADV-001 ADV-002 ADV-003 ADV-004].freeze

def scan_edit_test_date
  @scan_edit_test_date ||= Date.today
end

def scan_edit_serial_number
  @scan_edit_serial_number ||= "SN-SCAN-#{SecureRandom.hex(8).upcase}"
end

def scan_edit_invoice_number
  @scan_edit_invoice_number ||= "INV-SCAN-#{SecureRandom.hex(8).upcase}"
end

def scan_edit_all_field_values
  @scan_edit_all_field_values ||= begin
    date = scan_edit_test_date
    suffix = Faker::Alphanumeric.alphanumeric(number: 6).upcase
    {
      serial_number: scan_edit_serial_number,
      properties: {
        "mac_address" => "AA:BB:CC:DD:EE:#{suffix[0, 2]}",
        "imei_number" => "35#{suffix}#{SecureRandom.random_number(10**6).to_s.rjust(6, "0")}",
        "reference" => "invoice",
        "warranty_expiration" => date,
        "contract_expiration" => date
      },
      name: "Scan Edit Item Name",
      note: "Scan edit note text",
      retired_reason: "Retired for scan edit test",
      is_broken: true,
      is_incomplete: true,
      is_borrowable: false,
      status_note: "Scan edit status note all fields",
      is_inventory_relevant: true,
      responsible: "Responsible Person Scan",
      user_name: "Typical usage scan",
      invoice_number: scan_edit_invoice_number,
      invoice_date: date,
      price: "150.00",
      shelf: "A-01",
      supplier_name: "Test Supplier",
      building_name: "general building",
      room_name: "general room"
    }
  end
end

def ensure_search_edit_property_fields
  [
    {id: "properties_ampere", label: "Ampère", attribute: "ampere", position: 0},
    {id: "properties_electrical_power", label: "Power consumption in kw/h",
     attribute: "electrical_power", position: 1}
  ].each do |spec|
    next if Field[id: spec[:id]]

    Field.create(
      id: spec[:id],
      active: true,
      dynamic: true,
      position: spec[:position],
      data: Sequel.pg_jsonb(
        label: spec[:label],
        type: "text",
        group: "Eigenschaften",
        attribute: ["properties", spec[:attribute]],
        target_type: "item",
        permissions: {role: "inventory_manager", owner: false}
      )
    )
  end
end

step "there is a model :model_name with :n advanced search items in pool :pool_name" do |model_name, n, pool_name|
  ensure_search_edit_property_fields

  pool = InventoryPool.find(name: pool_name)
  model = LeihsModel.find(product: model_name) ||
    FactoryBot.create(:leihs_model, product: model_name)

  ADVANCED_SEARCH_CODES.first(n.to_i).each do |code|
    FactoryBot.create(:item,
      inventory_code: code,
      is_borrowable: true,
      leihs_model: model,
      responsible: pool,
      owner: pool)
  end
end

step "the item :code has status note :value" do |code, value|
  item = Item.find(inventory_code: code)
  expect(item.reload.status_note).to eq(value)
end

def assert_item_has_all_built_in_scan_edit_values(code)
  item = Item.find(inventory_code: code).reload
  expected = scan_edit_all_field_values
  props = (item.properties || {}).transform_keys(&:to_s)

  expect(item.serial_number).to eq(expected[:serial_number])
  expect(item.name).to eq(expected[:name])
  expect(item.note).to eq(expected[:note])
  expect(item.retired_reason).to eq(expected[:retired_reason])
  expect(item.is_broken).to be(true)
  expect(item.is_incomplete).to be(true)
  expect(item.is_borrowable).to be(false)
  expect(item.status_note).to eq(expected[:status_note])
  expect(item.is_inventory_relevant).to be(true)
  expect(item[:responsible]).to eq(expected[:responsible])
  expect(item.user_name).to eq(expected[:user_name])
  expect(item.invoice_number).to eq(expected[:invoice_number])
  expect(item.shelf).to eq(expected[:shelf])
  expect(item.retired).not_to be_nil

  expect(props["mac_address"]).to eq(expected[:properties]["mac_address"])
  expect(props["imei_number"]).to eq(expected[:properties]["imei_number"])
  expect(props["reference"]).to eq(expected[:properties]["reference"])
  expect(Date.parse(props["warranty_expiration"].to_s)).to eq(expected[:properties]["warranty_expiration"])
  expect(Date.parse(props["contract_expiration"].to_s)).to eq(expected[:properties]["contract_expiration"])

  expect(item.invoice_date).to eq(expected[:invoice_date])
  expect(item.last_check).to eq(expected[:invoice_date])
  expect(item.price.to_f).to eq(expected[:price].to_f)

  supplier = Supplier.find(name: expected[:supplier_name])
  expect(item.supplier_id).to eq(supplier.id)

  building = Building.find(name: expected[:building_name])
  room = Room.find(name: expected[:room_name], building_id: building.id)
  expect(item.room_id).to eq(room.id)
end

step "the item :code has all built-in scan-edit field values" do |code|
  assert_item_has_all_built_in_scan_edit_values(code)
end

step "all advanced search items have all built-in scan-edit field values" do
  ADVANCED_SEARCH_CODES.each do |code|
    assert_item_has_all_built_in_scan_edit_values(code)
  end
end

def search_edit_bulk_field_values
  {
    ampere: "16A",
    electrical_power: "2.5",
    note: "Search edit bulk note",
    shelf: "B-02",
    status_note: "Search edit bulk status",
    is_borrowable: false,
    is_incomplete: true,
    is_broken: true,
    building_name: "general building",
    room_name: "general room"
  }
end

def set_search_edit_bulk_fields
  values = search_edit_bulk_field_values
  idx = 0

  add_scan_edit_patch_field(idx, "Ampère")
  fill_scan_edit_text(idx, values[:ampere])
  idx += 1

  add_scan_edit_patch_field(idx, "Borrowable")
  click_scan_edit_radio(idx, values[:is_borrowable] ? "true" : "false")
  idx += 1

  add_scan_edit_patch_field(idx, "Building")
  fill_scan_edit_autocomplete(idx, values[:building_name], values[:building_name])
  idx += 1
  expect(page).to have_content("Room", wait: 5)
  fill_scan_edit_autocomplete(idx, values[:room_name], values[:room_name])
  idx += 1

  add_scan_edit_patch_field(idx, "Completeness")
  click_scan_edit_radio(idx, values[:is_incomplete] ? "true" : "false")
  idx += 1

  add_scan_edit_patch_field(idx, "Note")
  fill_scan_edit_text(idx, values[:note])
  idx += 1

  add_scan_edit_patch_field(idx, "Power consumption in kw/h")
  fill_scan_edit_text(idx, values[:electrical_power])
  idx += 1

  add_scan_edit_patch_field(idx, "Shelf")
  fill_scan_edit_text(idx, values[:shelf])
  idx += 1

  add_scan_edit_patch_field(idx, "Status note")
  fill_scan_edit_text(idx, values[:status_note])
  idx += 1

  add_scan_edit_patch_field(idx, "Working order")
  click_scan_edit_radio(idx, values[:is_broken] ? "true" : "false")
end

def assert_item_has_search_edit_bulk_values(code)
  item = Item.find(inventory_code: code).reload
  expected = search_edit_bulk_field_values
  props = (item.properties || {}).transform_keys(&:to_s)

  expect(props["ampere"]).to eq(expected[:ampere])
  expect(props["electrical_power"]).to eq(expected[:electrical_power])
  expect(item.note).to eq(expected[:note])
  expect(item.shelf).to eq(expected[:shelf])
  expect(item.status_note).to eq(expected[:status_note])
  expect(item.is_borrowable).to be(expected[:is_borrowable])
  expect(item.is_incomplete).to be(expected[:is_incomplete])
  expect(item.is_broken).to be(expected[:is_broken])

  building = Building.find(name: expected[:building_name])
  room = Room.find(name: expected[:room_name], building_id: building.id)
  expect(item.room_id).to eq(room.id)
end

step "all advanced search items have search-edit bulk field values" do
  ADVANCED_SEARCH_CODES.each do |code|
    assert_item_has_search_edit_bulk_values(code)
  end
end
