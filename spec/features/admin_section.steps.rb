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

step "I create field: :attr :type" do |attr, type|
  first(:button, "Add Field").click

  check "Active"
  fill_in "data:attribute", with: attr
  fill_in "data:label", with: attr

  select type, from: "data:type"

  # Only fill the two input fields for select/radio/checkbox
  if %w[Select Radio Checkbox].include?(type)
    within(".mt-3.ml-3") do
      first(".form-control").set("UI Label for #{attr}")
      all(".form-control")[1].set("DB Value for #{attr}")
    end
  end

  within("#data\\:group") do
    choose("Custom")
    find("div.form-check input.form-control").set("prop-group")
  end

  click_button "Save"
end

step "I see :count inventory field rows" do |count|
  within('table.inventory-fields tbody') do
    expect(all('tr.inventory-field').size).to eq(count.to_i)
  end
end

step "I activate field" do
  first(:button, "Edit field status").click # ← click first matching button

  id = "all-switch"
  page.execute_script("document.getElementById('#{id}').click()")

  click_button "Save"
end

step "I see :count test-group entries" do |count|
  within '#fields\\.prop-group\\.title' do
    fields = all('[name^="properties_test_"]')
    expect(fields.size).to eq(count.to_i)
  end
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
