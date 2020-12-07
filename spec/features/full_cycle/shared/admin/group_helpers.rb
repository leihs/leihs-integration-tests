def create_group(opts={})
  opts = opts.with_indifferent_access
  visit '/admin/'
  click_on 'Groups'
  click_on 'Create group'
  wait_until {current_path == '/admin/groups/create' }
  wait_until { all("input#name").count == 1 }
  fill_in 'name', with: (opts[:name] || Factory::Name.unique.name)
  click_on 'Create'
  wait_until {current_path != '/admin/groups/create' }
  wait_until { current_path.match? %r'/admin/groups/[^/]+' }
  Group.find(id: current_path.split('/').last)
end

def add_user_to_group user, group
  visit "/admin/groups/#{group.id}"
  click_on "Users"
  select "members and non-members", from: "Membership"
  fill_in 'Search', with: user.email
  wait_until { all("tr.user", text: 'Add').count == 1}
  within find("tr.user") { click_on "Add" }
  wait_until { all("tr.user", text: "Remove").count == 1 }
end

