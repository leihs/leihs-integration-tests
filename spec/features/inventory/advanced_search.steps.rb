def search_edit_filter_q_in_url?
  query = URI.parse(current_url).query.to_s
  Rack::Utils.parse_nested_query(query).key?("filter_q")
end

def await_search_edit_debounce
  sleep 0.4
end

def click_search_edit_add_filter_prompt
  # Prompt is a native <button> whose on-click appends an OR group to the form.
  # filter_q is written later by the 300ms debounced form watch — not on this click.
  if page.has_css?('[data-test-id="add-search-filter-prompt"]', wait: 2)
    page.execute_script(<<~JS)
      document.querySelector('[data-test-id="add-search-filter-prompt"]').click()
    JS
  else
    find(:button, text: /Add filters to start your search|fügen sie filter hinzu/i).click
  end
end

def select_search_edit_field(index, label)
  find(%([data-test-id="or-0-field-select-#{index}"])).click
  within('[data-test-id="field-options"]') do
    find("span", text: label, match: :first).click
  end
  page.send_keys :escape
  sleep 0.1
end

step "I go to the search-edit page of pool :name" do |name|
  @pool ||= InventoryPool.find(name: name)
  visit "/inventory/#{@pool.id}/search-edit"
  wait_until { current_path.match %r{^/inventory/#{@pool.id}/search-edit} }
end

step "I add a search filter" do
  click_search_edit_add_filter_prompt
  expect(page).to have_css('[data-test-id="or-0-field-select-0"]', wait: 10)
  select_search_edit_field(0, "Inventory Code")
  await_search_edit_debounce
  find("input[name='$or.0.$and.0.value']").set("ADV")
  await_search_edit_debounce
  wait_until(60, sleep_secs: 0.3) { search_edit_filter_q_in_url? }
end

step "I see :count search result items" do |count|
  expect(search_edit_filter_q_in_url?).to be(true)
  expect(page).to have_css('[data-test-id="edit-button"]', wait: 60)
  wait_until(30, sleep_secs: 0.3) { all("tbody tr").size == count.to_i }
end

step "I filter search results by inventory code :code" do |code|
  find("input[name='$or.0.$and.0.value']").set(code)
  await_search_edit_debounce
end

step "I select the search result for inventory code :code" do |code|
  within find("tbody tr", text: code) do
    find('button[role="checkbox"]').click
  end
end

step "I bulk edit status note to :value" do |value|
  click_on "edit-button"
  expect(page).to have_content("Add field")

  within find('[id="patch-item-form"]') do
    click_on "field-select-0"
  end
  within find('[data-test-id="field-options"]') do
    find(:button, text: "Status note", match: :first).click
  end

  find("textarea[name='update.0.value']").set(value)
  click_on "apply-button"
  expect(page).to have_content("1 Items was successfully updated")
end

step "I select all search result items" do
  ADVANCED_SEARCH_CODES.each do |code|
    within find("tbody tr", text: code) do
      find('button[role="checkbox"]').click
    end
  end
  within find('[data-test-id="edit-button"]') do
    expect(page).to have_content("4", wait: 10)
  end
end

step "I open the search-edit bulk edit form" do
  click_on "edit-button"
  expect(page).to have_content("Add field")
  expect(page).to have_css('[data-test-id="field-select-0"]', wait: 10)
end

step "I set search-edit bulk field values" do
  set_search_edit_bulk_fields
end

step "I apply the search-edit bulk edit form" do
  apply_btn = find('button[data-test-id="apply-button"]', wait: 10)
  scroll_and_click(apply_btn)
  expect(page).to have_content(/4 Items (was|were) successfully updated/i, wait: 60)
end
