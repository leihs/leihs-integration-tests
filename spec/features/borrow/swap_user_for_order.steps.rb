step "I visit the page of order :purpose in pool :pool_name in legacy" do |purpose, pool_name|
  pool = InventoryPool.find(name: pool_name)
  order = Order.find(purpose: purpose, inventory_pool_id: pool.id)
  visit "/manage/#{order.inventory_pool_id}/orders/#{order.id}/edit"
end

step "I visit the page of order :purpose in legacy" do |purpose|
  order = Order.find(purpose: purpose)
  visit "/manage/#{order.inventory_pool_id}/orders/#{order.id}/edit"
end

step "I change the orderer to :full_name" do |full_name|
  step 'I click on "Change orderer"'
  within '.modal' do
    find('input#user-id', match: :first).set full_name
    find('.ui-menu-item a', match: :first, text: full_name).click
    find(".button[type='submit']", match: :first).click
  end
end

step "I click on the order :title" do |title|
  find(".ui-list-card", text: title).click
end
