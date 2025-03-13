step "I visit the daily section of pool :name in legacy" do |name|
  pool = InventoryPool.find(name: name)
  visit "/manage/#{pool.id}/daily"
end

step "the current path are the entitlement groups of pool :name" do |name|
  pool = InventoryPool.find(name: name)
  expect(current_path).to eq "/manage/#{pool.id}/groups"
end

step "I should see a notice with a link to the admin" do
  expect(page).to have_selector(
    ".notice",
    text: "Except for the management of entitlement groups are all other functions in the Admin section."
  )
end

step "I click on the link in the notice" do
  find(".notice a").click
end

step "I am redirected to the manage section of the pool :name in admin" do |name|
  pool = InventoryPool.find(name: name)
  expect(current_path).to eq "/admin/inventory-pools/#{pool.id}"
end
