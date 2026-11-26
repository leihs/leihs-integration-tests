def visit_borrow_pool_show(pool)
  visit "/borrow/inventory-pools"
  card = get_ui_list_card_by_title(pool.name)
  expect(card).to be
  card.click
  wait_until { page.has_css?("h1", text: pool.name) }
end

def expect_borrow_pool_pickup_locations_section(visible:, location_name: nil, description: nil)
  if visible
    section = find_ui_section(title: "Alternative pickup locations")
    expect(section).to be
    expect(page).to have_content(location_name) if location_name
    expect(page).to have_content(description) if description
  else
    expect(page).not_to have_content("Alternative pickup locations")
    expect(page).not_to have_content(location_name) if location_name
  end
end

def add_model_to_borrow_cart(model, pickup_location: nil)
  visit "/borrow/models/#{model.id}"
  click_on "Add item"
  wait_until { page.has_button?("Add", wait: 15) }

  if pickup_location
    select(pickup_location, from: "Pickup location")
  else
    expect(page).not_to have_select("Pickup location")
  end

  click_on "Add"
  if page.has_button?("OK", wait: 5)
    click_on "OK"
  end
end

def submit_borrow_cart_order(title)
  find(".ui-cart-item-link").click
  click_on "Send order"
  fill_in "title", with: title
  click_on "Send"
  click_on "OK" if page.has_button?("OK", wait: 5)
  CustomerOrder.find(title: title)
end

def legacy_order_for_customer_order(pool, customer_order)
  Order.find(customer_order_id: customer_order.id, inventory_pool_id: pool.id)
end

def visit_legacy_open_orders(pool)
  visit "/manage/#{pool.id}/daily"
  click_on "Open Orders"
  wait_until { current_path == "/manage/#{pool.id}/orders" }
end

def open_legacy_order_edit_from_open_orders(order)
  wait_until { page.has_css?(".line[data-id='#{order.id}']") }
  line = find(".line[data-id='#{order.id}']")
  within(line) do
    find(".dropdown-toggle").click
    click_link "Edit"
  end
  wait_until { current_path == "/manage/#{order.inventory_pool_id}/orders/#{order.id}/edit" }
  wait_until { page.has_content?("Availability loaded") }
end

def visit_legacy_order_edit(pool, order)
  visit "/manage/#{pool.id}/orders/#{order.id}/edit"
  wait_until { page.has_content?("Availability loaded") }
end

def expect_legacy_order_edit_page(order)
  expect(page).to have_css("h1", text: "Edit Order")
  expect(page).to have_current_path(%r{/manage/.+/orders/#{Regexp.escape(order.id)}/edit})
end

def expect_legacy_order_line_pickup_location(model, location_name:, present: true)
  line = find(".order-line", text: model.product)
  if present
    within(line) do
      expect(page).to have_selector("[data-pickup-location]", text: location_name)
    end
  else
    within(line) do
      expect(page).not_to have_selector("[data-pickup-location]")
    end
  end
end

def approve_legacy_order_from_edit_page
  find("[data-order-approve]").click
  wait_until { current_path.include?("/daily") }
end

def visit_legacy_hand_over(pool, user)
  visit "/manage/#{pool.id}/users/#{user.id}/hand_over"
  wait_until { page.has_content?("Availability loaded") }
end

def expect_legacy_hand_over_pickup_location(model, location_name:, present: true)
  line = find("#lines [data-line-type='item_line']", text: model.product)
  if present
    within(line) do
      expect(page).to have_selector("[data-pickup-location]", text: location_name)
    end
  else
    within(line) do
      expect(page).not_to have_selector("[data-pickup-location]")
    end
  end
end
