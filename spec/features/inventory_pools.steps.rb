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
