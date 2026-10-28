def visit_pool_pickup_locations(pool)
  visit "/admin/inventory-pools/#{pool.id}/pickup-locations/"
  wait_until { current_path.include?("pickup-locations") }
end

def create_pickup_location(pool, name:, description: nil)
  visit_pool_pickup_locations(pool)
  click_on "Add Pickup Location"
  fill_in "name", with: name
  fill_in "description", with: description if description
  click_on "Save"
  wait_until { PickupLocation.where(inventory_pool_id: pool.id, name: name).count == 1 }
  PickupLocation.where(inventory_pool_id: pool.id, name: name).first
end

def switch_checked?(id)
  find("##{id}", visible: :all).checked?
end

def within_visible_modal(title, &)
  wait_until { page.has_css?(".modal.show", text: title) }
  within(first(".modal.show", text: title), &)
end

def set_switch(id, checked:)
  return if switch_checked?(id) == checked

  find("label[for='#{id}']").click
  wait_until { switch_checked?(id) == checked }
end

def set_pickup_location_active(pool, location, active:)
  visit_pool_pickup_locations(pool)
  click_on location.name
  click_on "Edit"
  within_visible_modal("Edit Pickup Location") do
    set_switch("active", checked: active)
    click_on "Save"
  end
  wait_until { PickupLocation[location.id].active == active }
end

def set_alternative_pickup_locations(
  pool,
  enabled:,
  default_name: "Main Warehouse",
  transfer_buffer_before: 0,
  transfer_buffer_after: 0
)
  visit "/admin/inventory-pools/#{pool.id}/pickup-locations/?action=edit-pickup-location-settings"
  within_visible_modal("Edit Pickup Location Settings") do
    set_switch("enable_alternative_pickup_locations", checked: enabled)
    fill_in "default_pickup_location_name", with: default_name
    fill_in "transfer_buffer_before_pick_up", with: transfer_buffer_before.to_s
    fill_in "transfer_buffer_after_drop_off", with: transfer_buffer_after.to_s
    click_on "Save"
  end
  wait_until do
    pool = InventoryPool[pool.id]
    pool.enable_alternative_pickup_locations == enabled &&
      pool.default_pickup_location_name == default_name
  end
  InventoryPool[pool.id]
end
