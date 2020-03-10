def create_a_model pool
  visit "/manage/#{@pool.id}/models/new"
  product = Faker::Commerce.unique.product_name
  find("#product input").fill_in with: product
  click_on 'Save Model'
  wait_until { page.has_content? 'Model saved'}
  LeihsModel.find(product: product)
end

def create_an_item pool, model
  visit "/manage/#{@pool.id}/items/new"
  inv_code = model.product.split(" ").map(&:first).join() + "-" + rand(10**10).to_s
  find("input[name='item[inventory_code]']").fill_in with: inv_code
  find("input[title='Model']").fill_in with: model.product
  find("ul.ui-autocomplete a").click
  find("input[title='Building']").fill_in with: 'general building'
  find("ul.ui-autocomplete a").click
  find("input[title='Room']").fill_in with: 'general room'
  find("ul.ui-autocomplete a").click
  within('form #is_borrowable'){ choose 'OK' }
  click_on 'Save Item'
  wait_until { page.has_content? 'Item saved.'}
  Item.find(inventory_code: inv_code)
end

def order model
  visit '/borrow'
  find('input#search_term').fill_in with: @model.product
  click_on @model.product
  click_on 'Add to order'
  click_on 'Add'
  click_on 'Complete order'
  purpose = Faker::Lorem.unique.sentence
  find("textarea[name='purpose']").fill_in with: purpose
  click_on 'Submit Order'
  wait_until{ page.has_content? 'Your order has been successfully submitted' }
  Order.find(purpose: purpose)
end

def hand_over pool, order, model, item
  visit "/manage/#{pool.id}/daily"
  click_on "Open Orders"
  wait_until{ current_path == "/manage/#{pool.id}/orders" }
  find("a", exact_text: "Approve").click
  click_on "Hand Over"
  sleep 1
  find("input[data-assign-item]").send_keys :enter
  find("input[data-assign-item]").fill_in with: item.inventory_code
  find("a[title~='#{item.inventory_code}']").click
  click_on "Hand Over Selection"
  wait_until{ page.has_content? order.purpose }
  click_on "Hand Over"
  wait_until{ windows.size == 2 }
  switch_to_window(windows.second)
  wait_until{ current_path && current_path.match?(%r"/manage/[^/]+/contracts/[^/]+") }
  contract_id = current_path.split('/').last
  switch_to_window(windows.first)
  windows.second.try(:close)
  wait_until{ page.has_content? "Hand over complete" }
  click_on "Finish this hand over"
  wait_until{ "/manage/#{pool.id}/daily" }
  Contract.find(id: contract_id)
end

def take_back pool, order, model, item, contract
  click_on "Visits"
  click_on "Take Back"
  find("[data-line-type='item_line'] input[type='checkbox']").click
  click_on "Take Back Selection"
  within(".modal"){ click_on "Take Back" }
  click_on "Finish this take back"
end

