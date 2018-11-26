step "I am redirected to the inventory path of the pool" do
  expect(current_path).to eq "/manage/#{@pool.id}/inventory"
end
