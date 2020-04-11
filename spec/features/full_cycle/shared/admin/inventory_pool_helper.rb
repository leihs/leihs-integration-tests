def create_inventory_pool
  visit '/admin/'
  click_on 'Inventory-Pools'
  click_on 'Add'
  name = Faker::Company.unique.name
  fill_in 'name', with: name
  fill_in 'shortname', with: name.split(" ").map(&:first).join
  fill_in 'email', with: Faker::Internet.unique.email
  click_on 'Add'
  wait_until {current_path.match? %r"/admin/inventory-pools/\w{8}\-\w{4}\-\w{4}\-\w{4}\-\w{12}" }
  id = current_path.split('/').last
  InventoryPool.find(id: id)
end


def assign_user_to_pool user, pool, role = 'customer'
  visit "/admin/inventory-pools/#{pool.id}/users/#{user.id}/direct-roles"
  uncheck role
  check role
  click_on 'Save'
  wait_until{ current_path == "/admin/inventory-pools/#{pool.id}/users/#{user.id}" }
end


def assign_group_to_pool group, pool, role = 'customer'
  visit "/admin/inventory-pools/#{pool.id}/groups/#{group.id}/roles"
  uncheck role
  check role
  click_on 'Save'
  wait_until { GroupAccessRight.find(group_id: group.id, role: role) }
end

