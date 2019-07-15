step "I am redirected to the inventory path of pool :name" do |name|
  pool = InventoryPool.find(name: name)
  expect(current_path).to eq "/manage/#{pool.id}/inventory"
end

step "I am redirected to the daily path of pool :name" do |name|
  pool = InventoryPool.find(name: name)
  expect(current_path).to eq "/manage/#{pool.id}/daily"
end
