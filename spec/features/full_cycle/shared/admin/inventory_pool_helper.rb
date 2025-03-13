def create_inventory_pool
  visit "/admin/"
  click_on "Inventory Pools"
  first(:link_or_button, "Add Inventory Pool").click
  name = Faker::Company.unique.name
  fill_in "name", with: name
  fill_in "shortname", with: name.split(" ").map(&:first).join
  fill_in "email", with: Faker::Internet.unique.email
  click_on "Save"
  wait_until { current_path.match? %r"/admin/inventory-pools/\w{8}-\w{4}-\w{4}-\w{4}-\w{12}" }
  id = current_path.split("/").last
  InventoryPool.find(id: id)
end

def assign_user_to_pool user, pool, role = "customer"
  visit "/admin/inventory-pools/#{pool.id}/users/#{user.id}"
  within ".direct-roles" do
    click_on "Edit"
  end
  wait_until { !all(".modal").empty? }
  uncheck "customer"
  sleep 1
  check role
  click_on "Save"
  wait_until { AccessRight.find(user_id: user.id, role: role) }
  # visit "/admin/inventory-pools/#{pool.id}/users/#{user.id}"
  within(".effective-roles") do
    expect(find_field(role, disabled: true)).to be_checked
  end
end

def assign_group_to_pool group, pool, role = "customer"
  visit "/admin/inventory-pools/#{pool.id}/groups/#{group.id}/roles"
  click_on "Edit"
  wait_until { !all(".modal").empty? }
  uncheck "customer"
  sleep 1
  check role
  click_on "Save"
  wait_until { GroupAccessRight.find(group_id: group.id, role: role) }
end

def click_on_toggle(id)
  page.execute_script("document.getElementById('#{id}').click()")
end

def set_pool_opening_hours pool, opening_hours = {}
  opening_hours = {
    Monday: "Open",
    Tuesday: "Open",
    Wednesday: "Open",
    Thursday: "Open",
    Friday: "Open",
    Saturday: "Open",
    Sunday: "Open"
  }.merge(opening_hours)
  visit "/admin/inventory-pools/#{pool.id}/opening-times"
  within "#workdays" do
    click_on "Edit"
  end
  opening_hours.each do |day, status|
    if (status == "Open") && !pool.workday.send(day.downcase)
      click_on_toggle "#{day.downcase}-switch"
    end
  end
  click_on "Save"
end
