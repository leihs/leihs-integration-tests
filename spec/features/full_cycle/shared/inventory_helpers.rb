require_relative "../../../../../inventory/spec/features/shared/common"

def expect_transportable_field_hidden_in_inventory(pool)
  visit "/inventory/#{pool.id}/list"
  click_on "Add inventory"
  click_on "New model"
  expect(page).not_to have_css("[data-id='transportable']")
end

def create_a_model_in_inventory(pool)
  visit "/inventory/#{pool.id}/list"
  click_on "Add inventory"
  click_on "New model"
  product = Faker::Commerce.unique.product_name
  fill_in "Product", with: product
  click_on "Create"
  wait_until { page.has_content?("Model successfully created") }
  LeihsModel.find(product: product)
end

def create_an_item_in_inventory(pool, model)
  visit "/inventory/#{pool.id}/list"
  click_on "Add inventory"
  click_on "New item"
  wait_until { page.has_selector?("button[data-test-id='is_borrowable-true']") }

  inventory_code = "#{pool.shortname}-#{rand(10**6)}"
  fill_in "Inventory Code", with: inventory_code

  find("button[data-test-id='model_id']").click
  fill_in "model_id-input", with: model.product
  click_on model.product

  find("button[data-test-id='is_borrowable-true']").click

  click_on "building_id"
  click_on "general building"
  click_on "Room"
  click_on "general room"

  click_on "Create"
  wait_until { page.has_text?("Item was successfully created") }
  Item.find(inventory_code: inventory_code)
end

def set_model_transportable(pool, model, transportable:)
  visit "/inventory/#{pool.id}/models/#{model.id}"
  wait_until { page.has_css?("[data-id='transportable']") }
  checkbox = find("[data-id='transportable']")
  if transportable
    checkbox.click unless checkbox["data-state"] == "checked"
    assert_checked(checkbox)
  else
    checkbox.click if checkbox["data-state"] == "checked"
    assert_unchecked(checkbox)
  end
  click_on "Save"
  wait_until { LeihsModel[model.id].transportable == transportable }
end
