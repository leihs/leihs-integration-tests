step "I am redirected to the inventory path of pool :name" do |name|
  pool = InventoryPool.find(name: name)
  expect(page).to have_current_path("/manage/#{pool.id}/inventory", ignore_query: true)
end

step "I am redirected to the daily path of pool :name" do |name|
  pool = InventoryPool.find(name: name)
  expect(page).to have_current_path("/manage/#{pool.id}/daily", ignore_query: true)
end
