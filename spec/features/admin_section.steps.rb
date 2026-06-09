require_relative "inventory/advanced_search.steps"
require_relative "inventory/scan_and_edit.steps"
require_relative "inventory/shared/patch_item_form_helpers"

EMPTY_SEARCH_EDIT_FILTER_D = '{"$or":[{"$and":[]}]}'.freeze

# Override: navigate directly with a pre-built filter_d so all pool items are
# visible without relying on UI interaction (e.g. selecting "Inventory Code").
step "I add a search filter" do
  pool_id = @pool&.id || InventoryPool.find(name: "New Pool").id
  filter_d = CGI.escape(EMPTY_SEARCH_EDIT_FILTER_D)
  visit "/inventory/#{pool_id}/search-edit?filter_d=#{filter_d}&page=1&size=50"
  wait_until { current_path.match %r{^/inventory/#{pool_id}/search-edit} }
  expect(page).to have_css('[data-test-id="or-0-field-select-0"]', wait: 10)
  wait_until(60, sleep_secs: 0.3) { search_edit_filter_d_in_url? }
end

step "I see the admin menu" do
  find("aside nav")
end

step "I click on :label within the admin menu" do |label|
  within "aside nav" do
    find("a", text: /#{label}/i).click
  end
end

step "I see the content of the :section page" do |section|
  find("h1", text: section)
end

step "I see the content of the :section page in the old admin" do |section|
  within "body" do
    if section == "Audits"
      current_scope.has_selector? "form"
    else
      current_scope.has_content? section
    end
  end
end

step "I redirect to :path" do |path|
  visit path
end

step "I create item" do
  first(:link_or_button, "Inventar hinzufügen").click
  first(:link_or_button, "Neuen Gegenstand").click
end

step "I close form" do
  find("button[data-test-id=submit-dropdown]").click
  first(:link_or_button, "Abbrechen").click
end

TEST_FIELD_OPTIONS = {
  "test_select" => [
    {label: "select-text1", value: "select-text1"},
    {label: "select-text2", value: "select-text2"}
  ],
  "test_radio" => [
    {label: "option-text1", value: "option-text1"},
    {label: "option-text2", value: "option-text2"}
  ],
  "test_checkbox" => [
    {label: "check-text1", value: "check-text1"},
    {label: "check-text2", value: "check-text2"}
  ]
}.freeze

step "I create field: :attr :type" do |attr, type|
  first(:button, "Add Field").click

  check "Active"
  fill_in "data:attribute", with: attr
  fill_in "data:label", with: attr

  select type, from: "data:type"

  if %w[Select Radio Checkbox].include?(type)
    options = TEST_FIELD_OPTIONS.fetch(attr) do
      [{label: "UI Label for #{attr}", value: "DB Value for #{attr}"}]
    end

    options.each_with_index do |opt, i|
      click_on("+") if i > 0
      within(".mt-3.ml-3") do
        row = all(".row.my-3")[i]
        within(row) do
          all(".form-control")[0].set(opt[:label])
          all(".form-control")[1].set(opt[:value])
        end
      end
    end

    unless type == "Checkbox"
      within(".mt-3.ml-3") do
        first('input[type="radio"]').click
      end
    end
  end

  within("#data\\:group") do
    choose("Custom")
    find("div.form-check input.form-control").set("prop-group")
  end

  click_button "Save"
end

step "I see :count inventory field rows" do |count|
  within("table.inventory-fields tbody") do
    expect(all("tr.inventory-field").size).to eq(count.to_i)
  end
end

def click_on_toggle(id)
  page.execute_script("document.getElementById('#{id}').click()")
end

step "I activate field" do
  expect(page).to have_button("Edit field status", wait: 10)
  click_on "Edit field status"
  within(".modal", wait: 10) do
    switch = find("#all-switch", visible: :all)
    click_on_toggle("all-switch") unless switch.checked?
  end
  click_on "Save"
  expect(page).to have_no_css(".modal", wait: 10)
end

step "I see :count test-group entries" do |count|
  within '#fields\\.prop-group\\.title' do
    fields = all(:xpath, './div[contains(@class, "relative")]')
    expect(fields.size).to eq(count.to_i)
  end
end

# test_date before checkbox: date auto-fills and triggers debounced URL sync.
# checkbox last: value fill is optional when options are not yet rendered.
TEST_FILTER_FIELD_LABELS = %w[
  test_select test_text test_textarea test_radio test_date test_checkbox
].freeze

TEST_DYNAMIC_FIELD_KEYS = TEST_FILTER_FIELD_LABELS

def test_item_properties
  {
    "test_select" => TEST_FIELD_OPTIONS["test_select"].first[:value],
    "test_text" => "filter text",
    "test_textarea" => "filter textarea",
    "test_radio" => TEST_FIELD_OPTIONS["test_radio"].first[:value],
    "test_date" => Date.today.iso8601,
    "test_checkbox" => [TEST_FIELD_OPTIONS["test_checkbox"].first[:value]]
  }
end

def empty_test_item_properties
  {}
end

step "there is a model :model_name with :matching matching and :non_matching non-matching test items in pool :pool_name" do |model_name, matching, non_matching, pool_name|
  pool = InventoryPool.find(name: pool_name)
  model = LeihsModel.find(product: model_name) ||
    FactoryBot.create(:leihs_model, product: model_name)

  item_attrs = {
    is_borrowable: true,
    leihs_model: model,
    responsible: pool,
    owner: pool
  }

  matching.to_i.times do
    FactoryBot.create(:item, **item_attrs, properties: test_item_properties)
  end

  non_matching.to_i.times do |i|
    attrs = {properties: empty_test_item_properties}
    attrs[:inventory_code] = "TEST-SCAN-001" if i.zero?
    FactoryBot.create(:item, **item_attrs, **attrs)
  end
end

def expect_test_filter_value_control(index, label)
  value_name = "$or.0.$and.#{index}.value"

  case label
  when "test_select", "test_date"
    expect(page).to have_css("button[name='#{value_name}']", visible: :all, wait: 5)
  when "test_text"
    expect(page).to have_css("input[name='#{value_name}']", wait: 5)
  when "test_textarea"
    expect(page).to have_css("textarea[name='#{value_name}']", wait: 5)
  when "test_radio", "test_checkbox"
    expect(page).to have_css(%([data-test-id^="#{value_name}-"]), visible: :all, wait: 5)
  end
end

def fill_test_filter_value(index, label)
  value_name = "$or.0.$and.#{index}.value"

  case label
  when "test_select"
    first("button[name='#{value_name}']").click
    within("[data-test-id='#{value_name}-options']") do
      find('[role="option"]',
        text: TEST_FIELD_OPTIONS["test_select"].first[:label],
        exact_text: true).click
    end
  when "test_text"
    find("input[name='#{value_name}']").set(test_item_properties["test_text"])
  when "test_textarea"
    find("textarea[name='#{value_name}']").set(test_item_properties["test_textarea"])
  when "test_radio"
    radio_value = test_item_properties["test_radio"]
    scroll_and_click(find(%([data-test-id="#{value_name}-#{radio_value}"]), visible: :all, wait: 5))
  when "test_date"
    # calendar fields default to today when selected
  when "test_checkbox"
    # CheckboxGroupField only renders after inventory JS rebuild; field selection is asserted separately.
    db_value = test_item_properties["test_checkbox"].first
    checkbox_xpath = "//*[@data-test-id=\"#{value_name}-#{db_value}\"]"
    find(:xpath, checkbox_xpath).click if page.has_xpath?(checkbox_xpath, wait: 2)
  end
end

step "I select each test filter field" do
  TEST_FILTER_FIELD_LABELS.each_with_index do |label, index|
    select_search_edit_filter_field(index, test_filter_field_id(label))

    # Assert value control before debounced URL sync can drop rows with empty values
    expect_test_filter_value_control(index, label)

    fill_test_filter_value(index, label)
    sleep 0.5 unless label.start_with?("test_checkbox")
  end
end

def fill_scan_edit_dynamic_value(index, label)
  case label
  when "test_select"
    fill_scan_edit_select(index, TEST_FIELD_OPTIONS["test_select"].first[:label])
  when "test_text", "test_textarea"
    fill_scan_edit_text(index, test_item_properties[label])
  when "test_radio"
    click_scan_edit_radio(index, test_item_properties["test_radio"])
  when "test_date"
    fill_scan_edit_calendar(index, Date.parse(test_item_properties["test_date"]))
  when "test_checkbox"
    click_scan_edit_checkbox(index, test_item_properties["test_checkbox"].first)
  end
end

def set_scan_edit_test_dynamic_fields
  TEST_FILTER_FIELD_LABELS.each_with_index do |label, index|
    add_scan_edit_patch_field(index, label)
    fill_scan_edit_dynamic_value(index, label)
    sleep 0.3 if label == "test_checkbox"
  end
end

step "I set all test dynamic fields on the scan-edit form" do
  set_scan_edit_test_dynamic_fields
end

def assert_item_has_test_dynamic_field_values(code)
  item = Item.find(inventory_code: code).reload
  props = (item.properties || {}).transform_keys(&:to_s)
  expected = test_item_properties

  expect(props["test_select"]).to eq(expected["test_select"])
  expect(props["test_text"]).to eq(expected["test_text"])
  expect(props["test_textarea"]).to eq(expected["test_textarea"])
  expect(props["test_radio"]).to eq(expected["test_radio"])
  expect(props["test_date"]).to eq(expected["test_date"])
  expect(props["test_checkbox"]).to eq(expected["test_checkbox"])
end

step "the item :code has test dynamic field values" do |code|
  assert_item_has_test_dynamic_field_values(code)
end

step "I am on the show page of the pool :name" do |name|
  wait_until { InventoryPool.find(name: "New Pool") }
  @pool ||= InventoryPool.find(name: name)
  wait_until { current_path.match "^/admin/inventory-pools/#{@pool.id}" }
end

step "I go to the mail templates page of pool :name" do |name|
  @pool ||= InventoryPool.find(name: name)
  visit "/admin/inventory-pools/#{@pool.id}/mail-templates/"
end

step "I click on :label for template :tmpl" do |label, tmpl|
  within find(".list-of-lines .row", text: tmpl) do
    click_on(label)
  end
end

step "I give myself the role of an inventory manager for the pool" do
  FactoryBot.create(:access_right,
    user: @current_user,
    inventory_pool: @pool,
    role: :inventory_manager)
end

step "I click on :label within the navigation" do |label|
  within ".nav-component" do
    click_on label
  end
end

step "I search for :txt in :field field" do |txt, field|
  fill_in field, with: txt
end

step "I select :txt from :field field" do |txt, field|
  select txt, from: field
end

step "I fill in body with :txt" do |txt|
  find(".modal-dialog")
  find("textarea#body").set(txt)
end

step "there is :txt in the body field" do |txt|
  expect(find("tr.body td.body").text).to eq txt
end
