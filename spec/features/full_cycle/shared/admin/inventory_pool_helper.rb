def create_inventory_pool
  visit '/admin/'
  click_on 'Inventory-Pools'
  click_on 'Create'
  name = Faker::Company.unique.name
  fill_in 'name', with: name
  fill_in 'shortname', with: name.split(" ").map(&:first).join
  fill_in 'email', with: Faker::Internet.unique.email
  click_on 'Create'
  wait_until {current_path.match? %r"/admin/inventory-pools/\w{8}\-\w{4}\-\w{4}\-\w{4}\-\w{12}" }
  id = current_path.split('/').last
  InventoryPool.find(id: id)
end


def assign_user_to_pool user, pool, role = 'customer'
  visit "/admin/inventory-pools/#{pool.id}/users/#{user.id}/direct-roles"
  uncheck "customer"
  sleep 1
  check role
  click_on 'Save'
  sleep 1
  visit "/admin/inventory-pools/#{pool.id}/users/#{user.id}"
  within(find('dl', text: 'Roles')) do
    expect(find_field(role, disabled: true)).to be_checked
  end
end


def assign_group_to_pool group, pool, role = 'customer'
  visit "/admin/inventory-pools/#{pool.id}/groups/#{group.id}/roles"
  uncheck "customer"
  sleep 1
  check role
  click_on 'Save'
  wait_until { GroupAccessRight.find(group_id: group.id, role: role) }
end

