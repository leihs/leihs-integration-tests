def create_group(opts={})
  opts = opts.with_indifferent_access
  visit '/admin/'
  click_on 'Groups'
  first(:link_or_button, 'Add Group').click
  wait_until { all("input#name").count == 1 }
  fill_in 'name', with: (opts[:name] || Factory::Name.unique.name)
  click_on 'Add'
  wait_until { current_path.match? %r'/admin/groups/[^/]+' }
  Group.find(id: current_path.split('/').last)
end

def add_user_to_group user, group
  visit "/admin/groups/#{group.id}"
  within ".nav-tabs" do
    click_on "Users"
  end
  select "members and non-members", from: "Membership"
  fill_in 'Search', with: user.email
  wait_until(sleep_secs: 0.5) { all("tr.user", text: 'Add').count == 1}
  within find("tr.user") { click_on "Add" }
  wait_until { all("tr.user", text: "Remove").count == 1 }
end

