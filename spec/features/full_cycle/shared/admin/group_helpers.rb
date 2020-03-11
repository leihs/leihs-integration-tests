def create_group(opts={})
  opts = opts.with_indifferent_access
  visit '/admin/'
  click_on 'Groups'
  click_on 'Add group'
  wait_until {current_path == '/admin/groups/add' }
  wait_until { all("input#name").count == 1 }
  fill_in 'name', with: (opts[:name] || Factory::Name.unique.name)
  click_on 'Add'
  wait_until { current_path.match? %r'/admin/groups/[^/]+' }
  Group.find(id: current_path.split('/').last)
end

def add_user_to_group user, group
  visit "/admin/groups/#{group.id}"
  click_on "Users"
  uncheck "Group users only"
  fill_in 'users-search-term', with: "#{user.firstname} #{user.lastname}"
  wait_until { all("table.users tbody tr").count == 1}
  within find("table.users") { click_on "Add" }
  wait_until { all("table.users", text: "Remove").count == 1 }
end

